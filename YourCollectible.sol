// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

import './HexStrings.sol';
import './ToColor.sol';
import {Base64} from './base64.sol';

contract YourCollectible is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{

    struct ERC721MetadataStructure {
        bool isImageLinked;
        string name;
        string description;
        string createdBy;
        string image;
        ERC721MetadataAttribute[] attributes;
    }

    struct ERC721MetadataAttribute {
        bool includeDisplayType;
        bool includeTraitType;
        bool isValueAString;
        string displayType;
        string traitType;
        string value;
    }
    
    using Strings for uint256;
    using HexStrings for uint160;
    using ToColor for bytes3;
    using Counters for Counters.Counter;
    string[] private _imageParts;
    string private _imageBaseURI;

    string constant private _SEED1 = '<SEED1>';
    string constant private _MARBLE_MATRIX = '<MARBLE_MATRIX>';
    string constant private _BASE_FREQ = '<BASE_FREQ>';
    string constant private _SEED2 = '<SEED2>';
    string constant private _COLOR_RED = '<COLOR_RED>';
    string constant private _COLOR_GREEN = '<COLOR_GREEN>';
    string constant private _COLOR_BLUE = '<COLOR_BLUE>';
    string constant private _MARBLE_COLOR = '<MARBLE_COLOR>';

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("WGMI Watch", "WGW") {

        _imageBaseURI = ""; // Set to empty string - results in on-chain SVG generation by default unless this is set later

        // Deploy default svg image
        _imageParts.push('<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">');
            _imageParts.push('<defs> <line x1="100" y1="17" x2="100" y2="23" style="stroke-width: 1px; stroke: black" id="smallTick"/> </defs>');
            _imageParts.push('<filter id="marble">');
                _imageParts.push('<feTurbulence result="mT1" baseFrequency="0.1" seed="');
                _imageParts.push(_SEED1);
                _imageParts.push('"/>');
                _imageParts.push('<feComposite operator="in" in="mT1" in2="SourceAlpha" result="mC1"/>');
                _imageParts.push('<feColorMatrix in="mC1" type="matrix" values="');
                _imageParts.push(_MARBLE_MATRIX);
                _imageParts.push('"/>');
            _imageParts.push('</filter>');
            _imageParts.push('<filter id="marble2">');
                _imageParts.push('<feTurbulence result="mT2" baseFrequency="0.0');
                _imageParts.push(_BASE_FREQ);
                _imageParts.push('" seed="');
                _imageParts.push(_SEED2);
                _imageParts.push('"/>');
                _imageParts.push('<feComposite operator="in" in="mT2" in2="SourceAlpha" result="mC2"/>');
                _imageParts.push('<feColorMatrix in="mC2" type="matrix" values="1 0 0 0 .');
                _imageParts.push(_COLOR_RED);
                _imageParts.push(' 0 1 0 0 .');
                _imageParts.push(_COLOR_GREEN);
                _imageParts.push(' 0 0 1 0 .');
                _imageParts.push(_COLOR_BLUE);
                _imageParts.push(' 0 0 0 1 0 "/>');
            _imageParts.push('</filter>');
            _imageParts.push('<style> .brand {font-size:8px; font-family:serif} </style>');
            _imageParts.push('<circle style="stroke: ');
            _imageParts.push(_MARBLE_COLOR);
            _imageParts.push('; stroke-width: 12px" cx="100" cy="100" r="80"></circle>');
            _imageParts.push('<circle style="stroke: #FFF; stroke-width: 12px; fill:#20B7AF" cx="100" cy="100" r="80" filter="url(#marble)"></circle>');
            _imageParts.push('<circle style="stroke-width: 0px" cx="100" cy="100" r="74"></circle>');
            _imageParts.push('<circle style="stroke: #FFF; stroke-width: 12px; fill:#20B7AF" cx="100" cy="100" r="68" filter="url(#marble2)"></circle>');
            _imageParts.push('<text x="96" y="23" class="brand">W</text>');
            _imageParts.push('<text x="17" y="102.8" class="brand">G</text>');
            _imageParts.push('<text x="176.5" y="102.8" class="brand">M</text>');
            _imageParts.push('<text x="98.8" y="183" class="brand">I</text>');
            _imageParts.push('<use href="#smallTick" transform="rotate(30, 100, 100)"/>');
            _imageParts.push('<use href="#smallTick" transform="rotate(60, 100, 100)"/>');
            _imageParts.push('<use href="#smallTick" transform="rotate(120, 100, 100)"/>');
            _imageParts.push('<use href="#smallTick" transform="rotate(150, 100, 100)"/>');
            _imageParts.push('<use href="#smallTick" transform="rotate(210, 100, 100)"/>');
            _imageParts.push('<use href="#smallTick" transform="rotate(240, 100, 100)"/>');
            _imageParts.push('<use href="#smallTick" transform="rotate(300, 100, 100)"/>');
            _imageParts.push('<use href="#smallTick" transform="rotate(330, 100, 100)"/>');
            _imageParts.push('<g stroke="black" stroke-width=".5">');
                _imageParts.push('<path d="M 97 75 C 98 72, 98 70, 100 45 C 102 70, 102 72, 103 75 L 101 100 L 99 100 Z" fill="white" id="hourhand">');
                    _imageParts.push('<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="130 100 100" to="490 100 100" begin="0s" dur="43200s" repeatCount="indefinite"/>');
                _imageParts.push('</path>');
                _imageParts.push('<path d="M 95 65 C 98 62, 98 60, 100 30 C 102 60, 102 62, 105 65 L 101 100 L 99 100 Z" fill="white" id="minutehand">');
                    _imageParts.push('<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="120 100 100" to="480 100 100" begin="0s" dur="3600s" repeatCount="indefinite"/>');
                _imageParts.push('</path>');
                _imageParts.push('<path d="M 99 75 C 99.5 72, 99.5 70, 100 30 C 100.5 70, 100.5 72, 101 75 v 36 A 2 5 0 1 1 99 111 Z" fill="#DBE4EB" id="secondhand">');
                    _imageParts.push('<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="42 100 100" to="402 100 100" begin="0s" dur="60s" repeatCount="indefinite"/>');
                _imageParts.push('</path>');
            _imageParts.push('</g>');
            _imageParts.push('<circle style="fill:#DBE4EB; stroke: black; stroke-width: 2px;" cx="100" cy="100" r="3"></circle>');
            _imageParts.push('</svg>');
    }

    // function _baseURI() internal pure override returns (string memory) {
    //     return "https://ipfs.io/ipfs/";
    // }

    // Mapping from token ID to owner address.
    mapping(uint256 => address) public _owners;
    // Mappings for SVG attributes
    mapping(uint256 => uint256) public s1;
    mapping (uint256 => uint256) public s2;
    mapping (uint256 => uint256) public cr;
    mapping (uint256 => uint256) public cg;
    mapping (uint256 => uint256) public cb;
    mapping (uint256 => uint256) public bf1;
    mapping (uint256 => string) public _marbleMatrix;
    mapping (uint256 => string) public _marbleColor;
    mapping (uint256 => string) public _caseColor;

    function mintItem(address to) public returns (uint256) {
        _tokenIdCounter.increment();
        uint256 id = _tokenIdCounter.current();
        _safeMint(to, id);

        bytes32 predictableRandom = keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this), id ));
        s1[id] = uint8(predictableRandom[0]);
        s2[id] = uint8(predictableRandom[1]);
        bf1[id] = (uint8(predictableRandom[3]) % 64 + uint8(predictableRandom[4]) % 64 + uint8(predictableRandom[5]) % 64 + uint8(predictableRandom[6]) % 64) / 8 + 4;
        uint8 _cshift = uint8(predictableRandom[11]) % 3;
        uint8 _cval = uint8(predictableRandom[12]) % 16;
        if (_cshift == 0) {
            cr[id] = _cval;
            cg[id] = 0;
            cb[id] = 0;
        } else if (_cshift == 1) {
            cr[id] = 0;
            cg[id] = _cval;
            cb[id] = 0;
        } else if (_cshift == 2) {
            cr[id] = 0;
            cg[id] = 0;
            cb[id] = _cval;
        }
        if (uint8(predictableRandom[13]) <= 11) {
            _marbleMatrix[id] = "0.83 0.83 0.83 0 0 0.69 0.69 0.69 0 0 0.22 0.22 0.22 0 0 0 1 0 1 0";
            _marbleColor[id] = "#d4af37";
            _caseColor[id] = "gold";
        } else {
            _marbleMatrix[id] = "0.86 0.86 0.86 0 0 0.89 0.89 0.89 0 0 0.92 0.92 0.92 0 0 0 1 0 1 0";
            _marbleColor[id] = "#dbe4eb";
            _caseColor[id] = "silver";
        }

        return id;
    }

    // function tokenMetadata(uint256 id) external view override returns (string memory) {        
    //     string memory base64Json = Base64.encode(bytes(string(abi.encodePacked(_getJson(id)))));
    //     return string(abi.encodePacked('data:application/json;base64,', base64Json));
    // }

    function _getJson(uint256 id) private view returns (string memory) {        
        string memory imageData = Base64.encode(bytes(_getSvg(id)));

        ERC721MetadataStructure memory metadata = ERC721MetadataStructure({
            isImageLinked: bytes(_imageBaseURI).length > 0, 
            name: string(abi.encodePacked("WGMI Watch ", id.toString())),
            description: string(abi.encodePacked('Algorithmically generated digital version of an analog watch.')),
            createdBy: "Mu",
            image: string(abi.encodePacked("data:image/svg+xml;base64,", imageData)),
            attributes: _getJsonAttributes(id)
        });

        return _generateERC721Metadata(metadata);
    }        

    function _getJsonAttributes(uint256 id) private view returns (ERC721MetadataAttribute[] memory) {

        ERC721MetadataAttribute[] memory metadataAttributes = new ERC721MetadataAttribute[](7);
        metadataAttributes[0] = _getERC721MetadataAttribute(false, true, false, "", "Seed 1", uint2str(s1[id]));
        metadataAttributes[1] = _getERC721MetadataAttribute(false, true, false, "", "Base Frequency", uint2str(bf1[id]));
        metadataAttributes[2] = _getERC721MetadataAttribute(false, true, false, "", "Seed 2", uint2str(s2[id]));
        metadataAttributes[3] = _getERC721MetadataAttribute(false, true, false, "", "Red", uint2str(cr[id]));
        metadataAttributes[4] = _getERC721MetadataAttribute(false, true, false, "", "Green", uint2str(cg[id]));
        metadataAttributes[5] = _getERC721MetadataAttribute(false, true, false, "", "Blue", uint2str(cb[id]));
        metadataAttributes[6] = _getERC721MetadataAttribute(false, true, true, "", "Case color", _caseColor[id]);
        return metadataAttributes;
    }    

    function _getERC721MetadataAttribute(bool includeDisplayType, bool includeTraitType, bool isValueAString, string memory displayType, string memory traitType, string memory value) private pure returns (ERC721MetadataAttribute memory) {
        ERC721MetadataAttribute memory attribute = ERC721MetadataAttribute({
            includeDisplayType: includeDisplayType,
            includeTraitType: includeTraitType,
            isValueAString: isValueAString,
            displayType: displayType,
            traitType: traitType,
            value: value
        });

        return attribute;
    }    

    function tokenURI(uint256 id) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(id), "not exist");

        string memory base64Json = Base64.encode(bytes(string(abi.encodePacked(_getJson(id)))));
        string memory _tokenURI = string(abi.encodePacked('data:application/json;base64,', base64Json));

        return _tokenURI;
    }


    // just need to pass in the token id and then all the other variables are mapped with that
    function _getSvg(uint256 id) private view returns (string memory) {
        bytes memory byteString;
        for (uint i = 0; i < _imageParts.length; i++) {
          if (_checkTag(_imageParts[i], _SEED1)) {
            byteString = abi.encodePacked(byteString, uint2str(s1[id]));
            console.log('s1', uint2str(s1[id]));
          } else if (_checkTag(_imageParts[i], _MARBLE_MATRIX)) {
            byteString = abi.encodePacked(byteString, _marbleMatrix[id]);
            console.log('Marble Matrix', _marbleMatrix[id]);
          } else if (_checkTag(_imageParts[i], _BASE_FREQ)) {
            byteString = abi.encodePacked(byteString, uint2str(bf1[id]));
            console.log('bf1', uint2str(bf1[id]));
          } else if (_checkTag(_imageParts[i], _SEED2)) {
            byteString = abi.encodePacked(byteString, uint2str(s2[id]));
            console.log('s2', uint2str(s2[id]));
          } else if (_checkTag(_imageParts[i], _COLOR_RED)) {
            byteString = abi.encodePacked(byteString, uint2str(cr[id]));
            console.log('cr', uint2str(cr[id]));
          } else if (_checkTag(_imageParts[i], _COLOR_GREEN)) {
            byteString = abi.encodePacked(byteString, uint2str(cg[id]));
            console.log('cg', uint2str(cg[id]));
          } else if (_checkTag(_imageParts[i], _COLOR_BLUE)) {
            byteString = abi.encodePacked(byteString, uint2str(cb[id]));
            console.log('cb', uint2str(cb[id]));
          } else if (_checkTag(_imageParts[i], _MARBLE_COLOR)) {
            byteString = abi.encodePacked(byteString, _marbleColor[id]);
            console.log('Marble color', _marbleColor[id]);
          } else {
            byteString = abi.encodePacked(byteString, _imageParts[i]);
          }
        }
        return string(byteString); 
    }

    function _generateERC721Metadata(ERC721MetadataStructure memory metadata) private pure returns (string memory) {
      bytes memory byteString;    
    
        byteString = abi.encodePacked(
          byteString,
          _openJsonObject());
    
        byteString = abi.encodePacked(
          byteString,
          _pushJsonPrimitiveStringAttribute("name", metadata.name, true));
    
        byteString = abi.encodePacked(
          byteString,
          _pushJsonPrimitiveStringAttribute("description", metadata.description, true));
    
        byteString = abi.encodePacked(
          byteString,
          _pushJsonPrimitiveStringAttribute("created_by", metadata.createdBy, true));
    
        if(metadata.isImageLinked) {
            byteString = abi.encodePacked(
                byteString,
                _pushJsonPrimitiveStringAttribute("image", metadata.image, true));
        } else {
            byteString = abi.encodePacked(
                byteString,
                _pushJsonPrimitiveStringAttribute("image", metadata.image, true));
        }

        byteString = abi.encodePacked(
          byteString,
          _pushJsonComplexAttribute("attributes", _getAttributes(metadata.attributes), false));
    
        byteString = abi.encodePacked(
          byteString,
          _closeJsonObject());
    
        return string(byteString);
    }

    function _getAttributes(ERC721MetadataAttribute[] memory attributes) private pure returns (string memory) {
        bytes memory byteString;
    
        byteString = abi.encodePacked(
          byteString,
          _openJsonArray());
    
        for (uint i = 0; i < attributes.length; i++) {
          ERC721MetadataAttribute memory attribute = attributes[i];

          byteString = abi.encodePacked(
            byteString,
            _pushJsonArrayElement(_getAttribute(attribute), i < (attributes.length - 1)));
        }
    
        byteString = abi.encodePacked(
          byteString,
          _closeJsonArray());
    
        return string(byteString);
    }

    function _getAttribute(ERC721MetadataAttribute memory attribute) private pure returns (string memory) {
        bytes memory byteString;
        
        byteString = abi.encodePacked(
          byteString,
          _openJsonObject());
    
        if(attribute.includeDisplayType) {
          byteString = abi.encodePacked(
            byteString,
            _pushJsonPrimitiveStringAttribute("display_type", attribute.displayType, true));
        }
    
        if(attribute.includeTraitType) {
          byteString = abi.encodePacked(
            byteString,
            _pushJsonPrimitiveStringAttribute("trait_type", attribute.traitType, true));
        }
    
        if(attribute.isValueAString) {
          byteString = abi.encodePacked(
            byteString,
            _pushJsonPrimitiveStringAttribute("value", attribute.value, false));
        } else {
          byteString = abi.encodePacked(
            byteString,
            _pushJsonPrimitiveNonStringAttribute("value", attribute.value, false));
        }
    
        byteString = abi.encodePacked(
          byteString,
          _closeJsonObject());
    
        return string(byteString);
    }

    function _openJsonObject() private pure returns (string memory) {        
        return string(abi.encodePacked("{"));
    }

    function _closeJsonObject() private pure returns (string memory) {
        return string(abi.encodePacked("}"));
    }

    function _openJsonArray() private pure returns (string memory) {        
        return string(abi.encodePacked("["));
    }

    function _closeJsonArray() private pure returns (string memory) {        
        return string(abi.encodePacked("]"));
    }

    function _pushJsonPrimitiveStringAttribute(string memory key, string memory value, bool insertComma) private pure returns (string memory) {
        return string(abi.encodePacked('"', key, '": "', value, '"', insertComma ? ',' : ''));
    }

    function _pushJsonPrimitiveNonStringAttribute(string memory key, string memory value, bool insertComma) private pure returns (string memory) {
        return string(abi.encodePacked('"', key, '": ', value, insertComma ? ',' : ''));
    }

    function _pushJsonComplexAttribute(string memory key, string memory value, bool insertComma) private pure returns (string memory) {
        return string(abi.encodePacked('"', key, '": ', value, insertComma ? ',' : ''));
    }

    function _pushJsonArrayElement(string memory value, bool insertComma) private pure returns (string memory) {
        return string(abi.encodePacked(value, insertComma ? ',' : ''));
    }

    function _checkTag(string storage a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    // function tokenURI(uint256 tokenId)
    //     public
    //     view
    //     override(ERC721, ERC721URIStorage)
    //     returns (string memory)
    // {
    //     return super.tokenURI(tokenId);
    // }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
