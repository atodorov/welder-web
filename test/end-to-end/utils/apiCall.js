// Functions working with BDCS API
const pageConfig = require('../config');
const utils = require('../../../core/utils');
const constants = require('../../../core/constants');
const BlueprintApi = require('../../../data/BlueprintApi');
const MetadataApi = require('../../../data/MetadataApi');

module.exports = {
  // BDCS API + Web service checking
  serviceCheck: () => Promise.all([utils.apiFetch('/api/v0/test'), utils.apiFetch(pageConfig.root)]),

  // Create a new blueprint
  newBlueprint: (blueprintName, done) => {
    BlueprintApi.postBlueprint(blueprintName)
      .then(() => { done(); })
      .catch((error) => { done(error); });
  },

  // Delete a blueprint
  deleteBlueprint: (blueprintName, done) => {
    BlueprintApi.deleteBlueprint(blueprintName)
      .then(() => { done(); })
      .catch((error) => { done(error); });
  },

  // Get module info
  moduleInfo: (moduleName, callback, done) => {
    MetadataApi.getData(constants.get_modules_info + moduleName)
      .then((resp) => {
        callback(resp.modules);
      })
      .catch((error) => { done(error); });
  },

  // Get total number of pcakges
  moduleListTotalPackages: (callback, done) => {
    utils.apiFetch(`${constants.get_modules_list}?limit=0&offset=0`)
      .then((resp) => {
        callback(resp.total);
      })
      .catch((error) => { done(error); });
  },
};
