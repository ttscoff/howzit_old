function fallback --description 'allow a fallback value for variable'
	if test (count $argv) = 1
		echo $argv
	else
		echo $argv[1..-2]
	end
end

function bld -d "Run howzit build system"
	howzit -r (fallback $argv build)
end
