// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title AcademicCertificates
 * @dev Contrato para emision y verificacion inmutable de titulos academicos.
 */
contract AcademicCertificates {
    // Variable inmutable almacenada directamente en el bytecode
    address public immutable universityOwner;

    struct Certificate {
        string studentName;
        string degreeName;
        uint64 issueDate;
        bool isValid;
    }

    // Identificador único (hash Keccak-256 o UUID) => Datos del certificado
    mapping(bytes32 => Certificate) public certificates;

    // Eventos para notificar a aplicaciones cliente (Web3.js/Ethers.js)
    event CertificateIssued(
        bytes32 indexed certId,
        string studentName,
        string degreeName
    );
    event CertificateRevoked(bytes32 indexed certId);

    modifier onlyUniversity() {
        require(
            msg.sender == universityOwner,
            "Error: Solo la universidad autorizada puede ejecutar esta accion."
        );
        _;
    }

    constructor() {
        universityOwner = msg.sender;
    }

    /**
     * @notice Emite un nuevo certificado académico
     * @param _certId Hash unico del certificado
     * @param _studentName Nombre completo del estudiante
     * @param _degreeName Nombre de la titulacion impartida
     */
    function issueCertificate(
        bytes32 _certId,
        string calldata _studentName,
        string calldata _degreeName
    ) external onlyUniversity {
        require(
            certificates[_certId].issueDate == 0,
            "Error: El certificado ya existe."
        );

        certificates[_certId] = Certificate({
            studentName: _studentName,
            degreeName: _degreeName,
            issueDate: uint64(block.timestamp),
            isValid: true
        });

        emit CertificateIssued(_certId, _studentName, _degreeName);
    }

    /**
     * @notice Revoca un certificado previo
     * @param _certId Hash unico del certificado a revocar
     */
    function revokeCertificate(bytes32 _certId) external onlyUniversity {
        require(
            certificates[_certId].issueDate != 0,
            "Error: El certificado no existe."
        );
        require(
            certificates[_certId].isValid,
            "Error: El certificado ya ha sido revocado previas veces."
        );

        certificates[_certId].isValid = false;
        emit CertificateRevoked(_certId);
    }

    /**
     * @notice Consulta la autenticidad y datos de un certificado
     * @param _certId Hash unico del certificado
     */
    function verifyCertificate(
        bytes32 _certId
    )
        external
        view
        returns (
            string memory studentName,
            string memory degreeName,
            uint64 issueDate,
            bool isValid
        )
    {
        Certificate memory cert = certificates[_certId];
        require(cert.issueDate != 0, "Error: Certificado no encontrado.");
        return (
            cert.studentName,
            cert.degreeName,
            cert.issueDate,
            cert.isValid
        );
    }
}
