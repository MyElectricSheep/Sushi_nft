import "./styles/App.css";
import GithubLogo from "./assets/GitHub-Mark-64px.png";
import React, { useEffect, useState, useRef } from "react";
import { ethers } from "ethers";
import sushiNFT from "./utils/sushiNFT.json";

// Constants
const GITHUB_HANDLE = "MyElectricSheep";
const GITHUB_LINK = `https://github.com/${GITHUB_HANDLE}`;
const OPENSEA_LINK = "";
const TOTAL_MINT_COUNT = 50;

const App = () => {
  const [currentAccount, setCurrentAccount] = useState("");
  const eth = useRef();

  // Make sure we can access Window.ethereum object
  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have Metamask");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
      eth.current = ethereum;
    }

    /*
     * Check if we're authorized to access the user's wallet
     * eth_accounts returns a list of addresses owned by the client
     * MetaMask uses the ethereum.request(args) method to wrap an RPC API. (RPC = Remote Procedure Call)
     * https://docs.metamask.io/guide/rpc-api.html
     * https://playground.open-rpc.org/?schemaUrl=https://raw.githubusercontent.com/ethereum/eth1.0-apis/assembled-spec/openrpc.json&uiSchema%5BappBar%5D%5Bui:splitView%5D=false&uiSchema%5BappBar%5D%5Bui:input%5D=false&uiSchema%5BappBar%5D%5Bui:examplesDropdown%5D=false
     */
    const accounts = await eth.current.request({ method: "eth_accounts" });

    /*
     * User can have multiple authorized accounts, we grab the first one if its there!
     */
    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found authorized account:", account);
      // account will be a wallet address of type 0x
      setCurrentAccount(account);
    } else {
      console.log("No authorized account found");
    }
  };

  const connectWallet = async () => {
    try {
      if (!eth.current) {
        alert("Get Metamask! https://metamask.io/");
        return;
      }

      /*
       *  Method to request access to accounts to the user
       *  eth_requestAccounts returns an array of a single, hexadecimal Ethereum address string.
       *  The request causes a MetaMask popup to appear.
       *  https://docs.metamask.io/guide/rpc-api.html#permissions
       */
      const [account] = await eth.current.request({
        method: "eth_requestAccounts",
      });

      /*
       * Print out public address once we authorize Metamask.
       */
      console.log("Connected!", account);
      setCurrentAccount(account);
    } catch (e) {
      console.log(e);
    }
  };

  const askContractToMintNFT = async () => {
    const CONTRACT_ADDRESS =
      process.env.REACT_APP_DEPLOYED_RINKEBY_CONTRACT_ADDRESS;

    try {
      if (eth.current) {
        /*
        https://docs.ethers.io/v5/api/providers/
        A Provider is an abstraction of a connection to the Ethereum network,
        providing a concise, consistent interface to standard Ethereum node functionality.
        Our provider here is Metamask
        https://github.com/MetaMask/providers
        */
        const provider = new ethers.providers.Web3Provider(eth.current);

        /* 
          https://docs.ethers.io/v5/api/signer/#signers
          A Signer in ethers is an abstraction of an Ethereum Account,
          which can be used to sign messages and transactions and send 
          signed transactions to the Ethereum Network to execute state
          changing operations.
        */
        const signer = provider.getSigner();

        const connectedContract = new ethers.Contract(
          CONTRACT_ADDRESS,
          sushiNFT.abi,
          signer
        );

        console.log("Ask wallet to pay gas");
        let nftTxn = await connectedContract.makeAnEpicNFT();

        console.log("Mining... please wait");
        await nftTxn.wait();

        console.log(
          `Mined, see transaction here: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`
        );
      }
    } catch (e) {
      console.log(e);
    }
  };

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  // Render Methods
  const renderNotConnectedContainer = () => (
    <button
      className="cta-button connect-wallet-button"
      onClick={connectWallet}
    >
      Connect to Wallet
    </button>
  );

  const renderConnectedContainer = () => (
    <button
      onClick={askContractToMintNFT}
      className="cta-button connect-wallet-button"
    >
      Mint NFT
    </button>
  );

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">My NFT Collection</p>
          <p className="sub-text">
            Each unique. Each beautiful. Discover your NFT today.
          </p>
          {currentAccount
            ? renderConnectedContainer()
            : renderNotConnectedContainer()}
        </div>
        <div className="footer-container">
          <img alt="Github Logo" className="github-logo" src={GithubLogo} />
          <a
            className="footer-text"
            href={GITHUB_LINK}
            target="_blank"
            rel="noreferrer"
          >
            built with⚡ by{" "}
            <span className="electric-sheep">{GITHUB_HANDLE}</span>
          </a>
        </div>
      </div>
    </div>
  );
};

export default App;
