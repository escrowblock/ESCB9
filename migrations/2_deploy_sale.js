var HMW = artifacts.require("HMW");

module.exports = function(deployer, network, accounts) {
  let members = ['0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
                 '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a'];

  let requiredConfirmationCount    = 7;
  let standardTimeAutoConfirmation = 7*24*60*60; // 1 week
  if(network == "testganache") {
    members = ['0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
               '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a',
               '0x1f0cf7afa0161b0d8e9ec076fb62bb00742d314a'];

    requiredConfirmationCount    = 2;
    standardTimeAutoConfirmation = 10*60; // 10 minutes
  }

  deployer.deploy(
    HMW,
    members,
    requiredConfirmationCount,
    standardTimeAutoConfirmation
  );
};
