import "./styles/App.css";
import GithubLogo from "./assets/GitHub-Mark-64px.png";
import React, { useEffect, useState, useRef } from "react";
import { ethers } from "ethers";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

import sushiNFT from "./utils/sushiNFT.json";
import SushiLoad from "./SushiLoad";
import GreatWave from "./GreatWave";
import ReactTooltip from "react-tooltip";

// Constants
const GITHUB_HANDLE = "MyElectricSheep";
const GITHUB_LINK = `https://github.com/${GITHUB_HANDLE}`;
const OPENSEA_LINK = process.env.REACT_APP_OPENSEA_LINK;
const CONTRACT_ADDRESS =
  process.env.REACT_APP_DEPLOYED_RINKEBY_CONTRACT_ADDRESS;
// String: hex code of the chainId of the Rinkeby test network
const RINKEBY_CHAIN_ID = "0x4";
// id of other networks besides Rinkeby
// https://docs.metamask.io/guide/ethereum-provider.html#table-of-contents
// https://chainlist.org/

const App = () => {
  const [currentAccount, setCurrentAccount] = useState("");
  const [howManyNFTs, setHowManyNFTs] = useState(0);
  const [loading, setLoading] = useState(false);
  const [chainId, setChaindId] = useState("");

  const eth = useRef();

  const checkIfNetworkIsRinkeby = async () => {
    try {
      const chainId = await eth.current.request({ method: "eth_chainId" });
      console.log("Connected to chain " + chainId);
      setChaindId(chainId);

      if (chainId !== RINKEBY_CHAIN_ID) {
        toast.error(
          `Hello there! sushiNFT is a work in progress.
           At the moment, we only support the Rinkeby Test Network.
           Hence, your wallet must be connected to Rinkeby to mint your sushiNFTs :)`
        );
      }
    } catch (e) {
      console.log(e);
    }
  };

  // Make sure we can access Window.ethereum object
  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have Metamask");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
      eth.current = ethereum;
      checkIfNetworkIsRinkeby();
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

      // Setup listener! This is for the case where a user comes to the site
      // and ALREADY have their wallet connected + authorized.
      setupEventListener();
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

      checkIfNetworkIsRinkeby();

      /*
       * Print out public address once we authorize Metamask.
       */
      console.log("Connected!", account);
      setCurrentAccount(account);

      // Setup listener! This is for the case where a user comes to the site
      // and connects their wallet for the first time.
      setupEventListener();
    } catch (e) {
      console.log(e);
    }
  };

  const successMsg = ({ closeToast }) => (
    <div>
      <span role="img" aria-label="sushi" className="sushi-icon">
        🍣
      </span>
      <p> Mint Successful!</p>
      <p> Here's the link to your NFT!</p>
      <p className="small-prints">
        {" "}
        (Note: the NFT can take
        <br /> ~10 minutes to appear on OpenSea)
      </p>
      <button
        className="success-button connect-wallet-button"
        onClick={closeToast}
      >
        <a
          href={`https://testnets.opensea.io/assets/${CONTRACT_ADDRESS}/1`}
          target="_blank"
          rel="noreferrer noopener"
          className="success-link"
        >
          Show NFT
        </a>
      </button>
    </div>
  );

  const setupEventListener = async () => {
    console.log("setting up event listener");
    try {
      if (eth.current) {
        const provider = new ethers.providers.Web3Provider(eth.current);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(
          CONTRACT_ADDRESS,
          sushiNFT.abi,
          signer
        );
        connectedContract.on(
          "NewSushiNFTMinted",
          (from, tokenId, numberOfNFTs) => {
            console.log(from, tokenId.toNumber(), numberOfNFTs.toNumber());
            setHowManyNFTs(numberOfNFTs.toNumber());
            toast(successMsg, {
              position: "top-center",
              autoClose: false,
              hideProgressBar: false,
              closeOnClick: false,
              pauseOnHover: true,
              draggable: true,
              progress: undefined,
            });
          }
        );
      }
    } catch (e) {
      console.log(e);
    }
  };

  const askContractToMintNFT = async () => {
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
        setLoading(true);

        console.log("Mining... please wait");
        await nftTxn.wait();

        console.log(
          `Mined, see transaction here: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`
        );
        setLoading(false);
      }
    } catch (e) {
      setLoading(false);
      if (e.message.includes("Each address may only own one sushiNFT")) {
        toast.error("Impossible to mint: you can only own one sushiNFT!");
      }
      if (e.message.includes("Only 100 sushiNFT can be minted")) {
        toast.error(
          "Oh no! The maximum number of sushiNFTs has already been minted!"
        );
      }
      console.log(e.message);
    }
  };

  const checkHowManyNFTs = async () => {
    try {
      if (eth.current) {
        const provider = new ethers.providers.Web3Provider(eth.current);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(
          CONTRACT_ADDRESS,
          sushiNFT.abi,
          signer
        );
        let checkHowMany = await connectedContract.howManyNFTs();
        setHowManyNFTs(checkHowMany.toNumber());
      }
    } catch (e) {
      console.log(e);
    }
  };

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  useEffect(() => {
    checkHowManyNFTs();
  }, [currentAccount, loading]);

  // Render Methods
  const renderNotConnectedContainer = () => (
    <button
      className="cta-button connect-wallet-button"
      onClick={
        chainId !== RINKEBY_CHAIN_ID ? checkIfNetworkIsRinkeby : connectWallet
      }
    >
      {chainId !== RINKEBY_CHAIN_ID
        ? "Connect to Rinkeby first"
        : "Connect to Wallet"}
    </button>
  );

  const renderConnectedContainer = () => {
    const classes = `cta-button ${
      loading ? "mint-button" : "connect-wallet-button"
    }`;

    return (
      <button
        onClick={askContractToMintNFT}
        className={classes}
        disabled={loading ? true : false}
      >
        {loading ? "Minting your NFT" : "Mint NFT"}
      </button>
    );
  };

  return (
    <div className="App">
      <a
        className="github-fork-ribbon"
        href={OPENSEA_LINK}
        target="_blank"
        rel="noreferrer noopener"
        data-ribbon="OpenSea Collection"
        title="OpenSea Collection"
      >
        OpenSea Collection
      </a>
      <ToastContainer
        position="top-center"
        autoClose={5000}
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
      />
      <GreatWave>
        <div className="container">
          <div className="header-container"></div>
          <div className="body-container">
            <p className="body gradient-text">
              sushiNFT{" "}
              <span role="img" aria-label="sushi" className="sushi-icon">
                🍣
              </span>
            </p>

            <p className="sub-text">
              Each unique. <br /> Each delicious. <br /> Discover your own
              sushiNFT today.
            </p>
            {currentAccount
              ? renderConnectedContainer()
              : renderNotConnectedContainer()}
            <p
              className="nft-count"
              data-tip="Only 365 sushiNFTs will ever be minted. Get yours now!"
              data-place="bottom"
            >
              {currentAccount && `${howManyNFTs} / 365 NFTs minted so far`}
            </p>
            {/* https://www.npmjs.com/package/react-tooltip */}
            <ReactTooltip />
          </div>
          {/* {loading && <SushiLoad />} */}

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
      </GreatWave>
    </div>
  );
};

export default App;
