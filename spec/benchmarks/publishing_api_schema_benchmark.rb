TestCase = Data.define(
  :base_path,
  :schema_name,
  :expected_response_min_size,
  :maximum_sql_query_count,
  :maximum_single_query_time,
  :maximum_overall_time,
)

RSpec.describe PublishingApiSchema do
  @test_cases = [
    TestCase.new(
      base_path: "/government/ministers",
      schema_name: "ministers_index",
      expected_response_min_size: 100_000,
      maximum_sql_query_count: 10,
      maximum_single_query_time: 0.2,
      maximum_overall_time: 2,
    ),
  ]

  @test_cases.each do |test_case|
    let(:query) { File.read(Rails.root.join("app/graphql/queries/#{test_case.schema_name}.graphql")) }

    it "should efficiently render #{test_case.schema_name} example - #{test_case.base_path}" do
      instrumentation_result = instrument do
        response = PublishingApiSchema.execute(query, variables: { base_path: test_case.base_path }).to_hash
        expect(response.key?("errors")).to be false
        edition = response.dig("data", "edition")
        expect(edition).to_not be nil
        expect(JSON.generate(edition).bytesize).to be > test_case.expected_response_min_size
      end

      aggregate_failures do
        expect(instrumentation_result.queries.count).to be <= test_case.maximum_sql_query_count
        expect(instrumentation_result.queries).to all(be_fast_query(threshold: test_case.maximum_single_query_time))
        expect(instrumentation_result).to be_fast_overall(threshold: test_case.maximum_overall_time)
      end
    end
  end
end