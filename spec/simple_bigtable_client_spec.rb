describe SimpleBigtableClient do
  let(:bigtable_client) { double(:bigtable_client) }
  subject { SimpleBigtableClient.new('instance', project_id: 'project_id', bigtable_client: bigtable_client)}

  context '#read_rows' do
    it "reads from bigtable_client" do
      expect(bigtable_client).to receive(:read_rows).with(
        'projects/project_id/instances/instance/tables/table',
        filter: nil,
        options: nil,
        rows: nil,
        rows_limit: nil
      ).and_return([])
      subject.read_rows('table', 'column_family').to_a
    end

    it "reads from bigtable_client with arguments" do
      expect(bigtable_client).to receive(:read_rows).with(
        'projects/project_id/instances/instance/tables/table',
        filter: nil,
        options: nil,
        rows: {row_keys: ['a', 'b'], row_ranges: [{start_key_closed: 'a', end_key_closed: 'b'}]},
        rows_limit: 10,
      ).and_return([])
      subject.read_rows(
        'table',
        'column_family',
        rows: {row_keys: ['a', 'b'], row_ranges: [{start_key_closed: 'a', end_key_closed: 'b'}]},
        limit: 10,
      ).to_a
    end

    it 'chunks cells into rows' do
      response = [
        double(:response_1, chunks: [
          double(:chunk1, row_key: 'first', qualifier: double(:column, value: 'a'), value: 'b'),
          double(:chunk1, row_key: 'first', qualifier: double(:column, value: 'c'), value: 'd'),
        ]),
        double(:response_2, chunks: [
          double(:chunk1, row_key: '', qualifier: double(:column, value: 'e'), value: 'f'),
          double(:chunk1, row_key: 'second', qualifier: double(:column, value: 'a'), value: 'b'),
          double(:chunk1, row_key: 'second', qualifier: double(:column, value: 'c'), value: 'd'),
          double(:chunk1, row_key: '', qualifier: double(:column, value: 'e'), value: 'f'),
        ])
      ]
      allow(bigtable_client).to receive(:read_rows).and_return(response)
      expect(subject.read_rows('table', 'column_family').to_a).to eq([
        {_row_key: 'first', a: 'b', c: 'd', e: 'f'},
        {_row_key: 'second', a: 'b', c: 'd', e: 'f'},
      ])
    end
  end

  context '#mutate_rows' do
    it 'calls mutate_rows with correct arguments' do
      entries = {
        first: {a: 'b', c: 'd'},
        second: {e: 'f'},
      }
      expect(bigtable_client).to receive(:mutate_rows).with(
        'projects/project_id/instances/instance/tables/table',
        [
          {
            row_key: 'first',
            mutations: [
              {set_cell: {column_qualifier: 'a', family_name: 'column_family', value: 'b'}},
              {set_cell: {column_qualifier: 'c', family_name: 'column_family', value: 'd'}},
            ]
          },
          {
            row_key: 'second',
            mutations: [
              {set_cell: {column_qualifier: 'e', family_name: 'column_family', value: 'f'}},
            ]
          },
        ]
      ).and_return([])
      subject.mutate_rows('table', 'column_family', entries)
    end

    it 'iterates on response from bigtable_client' do
      response = double(:response)
      entries = {
        first: {a: 'b', c: 'd'},
        second: {e: 'f'},
      }
      allow(bigtable_client).to receive(:mutate_rows).and_return(response)
      expect(response).to receive(:each)
      subject.mutate_rows('table', 'column_family', entries)
    end

    it 'if block is passed it is called with each reponse entry' do
      entries = {
        first: {a: 'b', c: 'd'},
        second: {e: 'f'},
      }
      allow(bigtable_client).to receive(:mutate_rows).and_return([1,2])
      result = []
      subject.mutate_rows('table', 'column_family', entries) do |element|
        result << element
      end
      expect(result).to eq([1,2])
    end
  end
end
