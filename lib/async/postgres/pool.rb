# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Async
	module Postgres
		class Pool
			# This pool doesn't impose a maximum number of open resources, but it WILL block
			# if there are no available resources and trying to allocate another one fails.

			def initialize(&block)
				@available = []
				@waiting = []
				
				@constructor = block
			end
			
			def acquire
				resource = wait_for_next_available
				
				begin
					yield resource
				ensure
					@available << resource
					
					if task = @waiting.pop
						task.resume
					end
				end
			end
			
			def close
				@available.each(&:close)
				@available.clear
			end
			
			def wait_for_next_available
				until resource = next_available
					@waiting << Fiber.current
					Task.yield
				end
				
				return resource
			end
			
			def next_available
				if @available.empty?
					return @constructor.call
				else
					return @available.pop
				end
			end
		end
	end
end
