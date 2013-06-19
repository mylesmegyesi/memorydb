require 'memorydb'
require 'memory_user'
require 'repository_examples'

describe MemoryDb do
  it_behaves_like 'repository', MemoryUser, MemoryUser, {primary_key: :id}
end
