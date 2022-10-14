local status_ok, git_conflict = pcall(require, "git-conflict")

if not status_ok then
	vim.notify("'git-conflict' plugin not found.")
	return
end

-- Mappings:
-- co — choose ours
-- ct — choose theirs
-- cb — choose both
-- c0 — choose none
-- ]x — move to previous conflict
-- [x — move to next conflict
git_conflict.setup()

-- Needs it for quicklist:
local status_ok_pqf, pqf = pcall(require, "pqf")
if not status_ok_pqf then
	vim.notify("'pqf' plugin not found.")
	return
end

pqf.setup()
