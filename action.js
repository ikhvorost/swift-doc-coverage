const core = require('@actions/core');
const { Octokit } = require("@octokit/core");
const fs = require('fs');
const dlog = require("./dlog.js");

const getPersent = (file) => {
  const data = fs.readFileSync(file, 'utf8');
  const json = JSON.parse(data);
  json.sources.map(source => source.totalCount )
  const totalCount = json.sources.map(s => s.totalCount).reduce((p, c) => p + c, 0);
  const undocumentedCount = json.sources.map(s => s.undocumented.length).reduce((p, c) => p + c, 0);
  let persent = ((totalCount - undocumentedCount) / totalCount) * 100;
  return persent;
};

const updateGist = async (token, description, file, content) => {
  const octokit = new Octokit({
    auth: token
  });

  // Get gists
  const payload = await octokit.request('GET /gists', {});

  // Find gist by description
  let item = payload.data.find(e => e.description === description);
  if(item !== undefined) {
    dlog.debug("Update existing gist...");

    const gist_id = item.id;
    await octokit.request(`PATCH /gists/${gist_id}`, {
      gist_id: gist_id,
      description: description,
      files: {
        [file]: {
          content: content
        }
      }
    });
  }
  else {
    dlog.debug("Create new gist...")
    
    await octokit.request('POST /gists', {
      description: description,
      public: true,
      files: {
        [file]: {
          content: content
        }
      }
    });
  }
  dlog.debug('DONE');
}

const badgeColor = (persent) => {
  if(persent <= 50) {
    return 'red';
  }
  if(persent < 70) {
    return 'yellow';
  }
  if(persent < 80) {
    return 'yellowgreen';
  }
  if(persent < 90) {
    return 'green';
  }
  return 'brightgreen'
}

try {
  const file = process.env.FILE;
  const token = process.env.TOKEN;
  const repository = process.env.REPOSITORY;

  if(file === undefined || token === undefined || repository === undefined) {
    throw new Error('No params.');
  }

  dlog.info('File:', file);
  dlog.info('Token:', token);
  dlog.info('Repository:', repository);

  const persent = getPersent(file);
  dlog.debug(`Coverage: ${persent.toFixed()}%`);
  const content = `{"schemaVersion": 1,"label":"swift-doc-coverage","message":"${persent.toFixed()}%","color":"${badgeColor(persent)}"}`;

  const outputFile = repository.substring(repository.lastIndexOf('/') + 1) + ".json";
  dlog.debug('Output file:', outputFile);
  updateGist(token, 'Swift Doc Coverage', outputFile, content);
}
catch (error) {
  dlog.error(error.message);
  core.setFailed(error.message);
}