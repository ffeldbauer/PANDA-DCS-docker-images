As a general rule, you should never push directly to the `master` branch!

This project uses the [topic branch workflow](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows).
This means that every addition or correction is kept in a separate git branch and reviewed there.
After successful review, it can be merged into the `master` branch.

The first step of doing any work on this project is to open a new [issue](https://git.gsi.de/panda/pandadcs/epics-docker/-/issues).

Each issue can get an assigne who is working on the topic and can have several [labels](https://git.gsi.de/panda/pandadcs/epics-docker/-/issues) assigned.

Each issue is assigned a number by GitLab which is should be included in the name of the topic branch. The schema is:

`<issue number>-<your name>-<brief topic>`

If issue number 42 was called “Write section about warp engine” and John Doe would be working on it, the branch would be called `42-john-warp-engine`.

Any new branch should always be based on the latest master branch on the server. To do that, use the following sequence of git commands (using John Doe's branch name as an example):

```bash
git fetch origin
git checkout -b 42-john-warp-engine remotes/origin/master
git push -u origin 42-john-warp-engine
```

The dummy branch name `42-john-warp-engine` would of course have to be replaced with your individual branch name.

After the work on the topic is finished and the content is ready to be merged into the `master` branch, open a [merge request](https://git.gsi.de/panda/pandadcs/epics-docker/-/merge_requests). This will invite people to review your work.
Changes to the topic branch are still possible after the merge request has been opened and are documented in the comment section of that merge request.

If your changes are accepted, Florian will merge them into the `master` branch.

All existing branches and their differences to the mainline can be viewed [here](https://git.gsi.de/panda/pandadcs/epics-docker/-/branches).

In addition to not pushing directly to `master`, nobody should push to another person's topic branch without asking that person for approval beforehand.
