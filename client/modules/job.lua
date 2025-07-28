-- Configuration
local Config = require("config.main")
local Functions = require("config.functions")

-- Locales
local locales = lib.loadJson(("locales.%s"):format(Config.Locale))

---@param shopData table
---@return boolean
local function checkJob(shopData)
	local jobName, jobGrade = lib.callback.await("cloud-shop:getJobData", false)
	log.debug(("[checkJob] Job Name: %s, Job Grade: %s"):format(jobName, jobGrade))

	if jobName ~= shopData.Requirement.Job.Name then
		Functions.Notify.Client({
			title = locales.notify.requirement.job.title,
			description = locales.notify.requirement.job.description:format(shopData.Requirement.Job.Label),
			type = locales.notify.requirement.job.type,
		})
		return false
	end

	if jobGrade < shopData.Requirement.Job.Grade then
		Functions.Notify.Client({
			title = locales.notify.requirement.job_grade.title,
			description = locales.notify.requirement.job_grade.description,
			type = locales.notify.requirement.job_grade.type,
		})
		return false
	end

	return true
end

return checkJob
