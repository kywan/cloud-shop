-- Configuration
local Functions = require("config.cfg_functions")
local Locales = require("config.cfg_locales")

---@param shopData table
---@return boolean
local function checkJob(shopData)
	local jobName, jobGrade = lib.callback.await("cloud-shop:getJobData", false)
	Print.Debug(("[checkJob] Job Name: %s, Job Grade: %s"):format(jobName, jobGrade))

	if jobName ~= shopData.Requirement.Job.Name then
		Functions.notify.client({
			title = Locales.notify.requirement.job.title,
			description = Locales.notify.requirement.job.description:format(shopData.Requirement.Job.Label),
			type = Locales.notify.requirement.job.type,
		})
		return false
	end

	if jobGrade < shopData.Requirement.Job.Grade then
		Functions.notify.client({
			title = Locales.notify.requirement.job_grade.title,
			description = Locales.notify.requirement.job_grade.description,
			type = Locales.notify.requirement.job_grade.type,
		})
		return false
	end

	return true
end

return checkJob
