RSpec::Matchers.define :be_fast_query do |threshold: 0.001|
  description { "be a SQL query that completes under #{threshold}s" }

  match do |query|
    @query = query
    @threshold = threshold
    query[:time] < threshold
  end

  failure_message do |query|
    sql = query[:sql]
    plan = begin
      ActiveRecord::Base.connection.execute("EXPLAIN (ANALYZE, BUFFERS) #{sql}")
    rescue StandardError => e
      [["(Failed to EXPLAIN: #{e.message})"]]
    end

    test_name = RSpec.current_example.description.parameterize
    fingerprint = Digest::MD5.hexdigest(sql)
    sql_filepath = "tmp/sql_#{test_name}_#{fingerprint}.sql"
    File.write(Rails.root.join(sql_filepath), sql)

    pretty_plan = plan.respond_to?(:values) ? plan.values.map(&:first).join("\n") : plan.to_s

    query_plan_filepath = "tmp/sql_#{test_name}_#{fingerprint}.plan"
    File.write(Rails.root.join(query_plan_filepath), pretty_plan)

    <<~MSG
      Expected SQL query to complete in under #{@threshold} seconds, but took #{query[:time]}s.

      SQL query is in: #{sql_filepath}
      Query plan is in: #{query_plan_filepath}
    MSG
  end
end
