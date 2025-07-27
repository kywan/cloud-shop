local Config = require("config.cfg_main")

local LogLevels = {
	verbose = { prefix = "^6[VERBOSE]^0 ", enabled = true },
	debug = { prefix = "^4[DEBUG]^0 ", enabled = true },
	info = { prefix = "^5[INFO]^0 ", enabled = true },
	warn = { prefix = "^8[WARN]^0 ", enabled = true },
	error = { prefix = "^1[ERROR]^0 ", enabled = true },
}

if Config.DebugMode == "prod" then
	LogLevels.verbose.enabled = false
	LogLevels.debug.enabled = false
elseif not Config.DebugMode then
	LogLevels.verbose.enabled = false
	LogLevels.debug.enabled = false
	LogLevels.info.enabled = false
	LogLevels.warn.enabled = false
	LogLevels.error.enabled = false
end

local function formatArgs(args)
	for index, value in ipairs(args) do
		args[index] = (value == nil) and "nil" or tostring(value)
	end
	return table.concat(args, " ")
end

local function log(level, ...)
	local args = { ... }
	local logLevelConfig = LogLevels[level]
	if not logLevelConfig or not logLevelConfig.enabled then return end

	local debugMessage = formatArgs(args)
	local formattedMessage = ("%s%s"):format(logLevelConfig.prefix, debugMessage)

	print(formattedMessage)
end

Print = {}

function Print.Verbose(...)
	log("verbose", ...)
end
function Print.Debug(...)
	log("debug", ...)
end
function Print.Info(...)
	log("info", ...)
end
function Print.Warn(...)
	log("warn", ...)
end
function Print.Error(...)
	log("error", ...)
end
