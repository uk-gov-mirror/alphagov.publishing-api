RSpec::Matchers.define :be_fast_overall do |threshold: 0.2|
  description { "complete overall benchmark in under #{threshold}s" }

  match do |result|
    @result = result
    result.overall_time < threshold
  end

  failure_message do |result|
    filepath = "tmp/stackprof_#{RSpec.current_example.description.parameterize}.json"
    File.write(Rails.root.join(filepath), JSON.generate(result.profile))
    <<~MSG
      Expected overall time to be less than #{threshold}s, but was #{result.overall_time.round(3)}s.
      StackProf profile saved to: #{filepath}
      Open it at https://www.speedscope.app/
    MSG
  end
end
