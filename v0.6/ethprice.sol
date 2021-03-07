pragma solidity ^0.6.0;


import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";

contract APIConsumer is ChainlinkClient {
  
    uint256 public volume;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    
    /**
     * Network: Kovan
     * Oracle: 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e
     * Job ID: 29fa9aa13bf1468788b7cc4a500a45b8
     * Fee: 0.1 LINK
     */
    constructor() public {
        setPublicChainlinkToken(); // setta il token pubblico della chainlink
        oracle = 0x7AFe1118Ea78C1eae84ca8feE5C65Bc76CcF879e; //  https://market.link/ 
        jobId = "29fa9aa13bf1468788b7cc4a500a45b8";  // https://market.link/
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }
    
    /**
     * Crea la request e la invia all'oracolo     
     */
    function requestVolumeData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Imposta url, request e paramentri
        request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");
        
        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"ETH":
        //    {"USD":
        //     {
        //      "VOLUME24HOUR": xxx.xxx,
        //     }
        //    }
        //   }
        //  }
        request.add("path", "RAW.ETH.USD.VOLUME24HOUR");
        
        // moltiplica per 1000000000000000000 per rimuovere i decimali
        int timesAmount = 10**18;
        request.addInt("times", timesAmount);
        
        // invia la request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * riceve la risposta
     */ 
    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId)
    {
        volume = _volume;
    }
}
