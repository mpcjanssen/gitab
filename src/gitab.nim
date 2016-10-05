import os

proc nakedBrachName(decoratedBranchName: string) : string =
  return tailDir(decoratedBranchName)

proc main() : void = 

  if execShellCmd("git status") != 0:
    quit("fatal: Current dir is not in a git repo", 1)
    
  if paramCount() == 0:
    quit("Please specify git branch to archive")

  let branch = paramStr(1)
  let archiveBranchName = "archive/" & nakedBrachName(branch)
  echo("Archiving ", branch, " to ", archiveBranchName)


  let isBranch = execShellCmd("git rev-parse --verify --quiet " & branch) == 0

  if isBranch:
    echo("Archiving branch " & branch)
  else:
    quit("fatal: Branch " & branch & " doesn't exist", 1)

  echo("Tagging as " & archiveBranchName)

  let code = execShellCmd("git tag " & archiveBranchName & " " & branch)
  if code != 0:
    quit("fatal: Tagging failed", 1)
    
  if execShellCmd("git push --tags") != 0:
    quit("fatal: Push failed", 1)

  let remoteDeleteBranch = ":" & branch
  if execShellCmd("git push origin " & remoteDeleteBranch) != 0:
    quit("fatal: Remote branch delete failed", 1)

  if execShellCmd("git branch -D " & nakedBrachName(branch)) != 0:
    quit("fatal: Local branch delete failed", 1)

when isMainModule:
  main()