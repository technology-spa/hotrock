# Pull Request Checklist
This is the checklist that I try to go through for every single pull request that I get. If you're wondering why it takes so long for me to accept pull requests, this is why. 
 
## General  
 
- [ ] Is this change useful to me, or something that I think will benefit others greatly? 
- [ ] Check for overlap with other PRs. 
- [ ] Think carefully about the long-term implications of the change. How will it affect existing projects that are dependent on this? How will it affect my projects? If this is complicated, do I really want to maintain it forever? Is there any way it could be implemented as a separate package, for better modularity and flexibility? 
 
## Check the Code 
 
- [ ] If it does too much, ask for it to be broken up into smaller PRs. 
- [ ] Is it consistent? 
- [ ] Review the changes carefully, line by line. Make sure you understand every single part of every line. Learn whatever you do not know yet. 
- [ ] Take the time to get things right. PRs almost always require additional improvements to meet the bar for quality. Be very strict about quality. This usually takes several commits on top of the original PR. 
 
## Check the Tests 
 
- [ ] Does it have tests? If not: 
 
  - [ ] Comment on the PR "Can you please add tests for this code to `test_blah.py`",  
 
- [ ] Do the tests pass for all of the following core test? If not, write a note in the PR, or fix them yourself. 
 
  - [ ] test one 
  - [ ] test two 
  - [ ] test three 
  - [ ] … 
  - [ ] test last  
 
## Check the Docs 
 
- [ ] Does it have docs? If not: 
 
  - [ ] Comment on the PR "Can you please add docs for this feature to `docs/usage.rst`" 
 
- [ ] If any new features are added, are they in `README.rst`? 
 
## Credit the Authors 
 
- [ ] Add name and URL to `AUTHORS.rst`. 
- [ ] Copy and paste title and PR number into `HISTORY.rst`. 
- [ ] Thank them for their hard work. 
 
## Close Issues 
 
- [ ] Merge the PR branch. This will close the PR's issue. 
- [ ] Close any duplicate or related issues that can now be closed. Write thoughtful comments explaining how the issues were resolved. 
 
## Release (optional) 
 
- [ ] Decide whether the changes in master make sense as a major, minor, or patch release. 
- [ ] Look at the clock. If you're tired, release later when you have time to deal with release problems. 
- [ ] Then follow all the steps in the [hyperlink: Release Checklist] 
 
