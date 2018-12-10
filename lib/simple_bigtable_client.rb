require "simple_bigtable_client/version"
require "google-cloud-bigtable"

class SimpleBigtableClient
  def initialize(instance, project_id: ENV['GOOGLE_CLOUD_PROJECT'], bigtable_client: Google::Cloud.new.bigtable)
    @instance = instance
    @bigtable_client = bigtable_client
    @project_id = project_id
  end

  def read_rows(table, column_family, rows: nil, filter: nil, limit: nil, options: nil)
    return to_enum(
      __method__,
      table,
      column_family,
      rows: rows,
      filter: filter,
      limit: limit,
      options: options
    ) unless block_given?
    cell_chunk_enumerator = @bigtable_client.read_rows(
      table_name(table),
      rows: rows,
      filter: filter,
      rows_limit: limit,
      options: options
    )
    prev_row_key = nil
    row_enumerator = cell_chunk_enumerator.lazy.flat_map(&:chunks).chunk do |cell_chunk|
      if cell_chunk.row_key == ""
        prev_row_key
      else
        prev_row_key = cell_chunk.row_key
      end
    end
    row_enumerator.each do |row_key, cell_chunks|
      row = cell_chunks.each_with_object(_row_key: row_key) do |cell_chunk, acc|
        acc[cell_chunk.qualifier.value.to_sym] = cell_chunk.value
      end
      yield(row)
    end
  end

  def mutate_rows(table, column_family, enumerator, slice_size: 100_000)
    enumerator.each_slice(slice_size) do |slice|
      entries = slice.map do |row_key, cells|
        {
          row_key: row_key.to_s,
          mutations: cells.map do |column_qualifier, value|
            {
              set_cell: {
                column_qualifier: column_qualifier.to_s,
                family_name: column_family,
                value: value.to_s
              }
            }
          end
        }
      end
      @bigtable_client.mutate_rows(table_name(table), entries).each do |element|
        yield element if block_given?
      end
    end
  end

  private

  def table_name(table)
    Google::Cloud::Bigtable::V2::BigtableClient.table_path(@project_id, @instance, table)
  end
end
