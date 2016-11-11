Git flow attempts to enforce good practices via a workflow convention, so that large teams can work together without breaking production codebases. It's very straightforward, and it can be useful in situations where more powerful gating systems with advanced CI are unavailable.

Projects have a development branch and a master branch. Developers clone the development branch, make a new branch with their changes, and then request that their changes be merged to the development branch.

When the code in the development branch is ready to be treated as a release, the development branch is merged into master. This ensures that master 'always works'. Master is tagged 'release'. Only the master branch is tagged, so the ready-to-release development branch must just be referred to via its sha1 in this process.

The git flow workflow makes sense in a world where the testing overhead doesn't make it worth testing every commit against a branch in order to ensure the branch is always functional.

git flow also includes the concept of hotfixes. The process for merging a hotfix to an old release is to create a branch off master, make the fix, and merge to master and the development branch. Be cautious; 'master' will be behind the current development branch, and the hotfix will not be merged in the same place in the history. This means you cannot assume that the state of the development branch at a given sha is the same as the state of the master branch at the same sha. If you make a lot of hotfixes, you will find yourself in a situation where a tagged release in master and the corresponding point in devel differ significantly; debugging these will not be straightforward. You also cannot fix any releases other than the most recent one, as it would change the (public) git history of the master branch.

There is a much prettier tutorial available here: 

https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
