module BenchmarkHelpers
  InstrumentationResult = Data.define(:queries, :overall_time, :profile)

  def instrument(&block)
    queries = []
    callback = lambda do |_name, start, finish, _id, payload|
      next if payload[:name].in?(%w[SCHEMA TRANSACTION])

      queries << { sql: payload[:sql], time: finish - start }
    end

    profile_data = nil
    time = Benchmark.realtime do
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        profile_data = StackProf.run(mode: :wall, raw: true, &block)
      end
    end

    InstrumentationResult.new(queries, time, profile_data)
  end
end
