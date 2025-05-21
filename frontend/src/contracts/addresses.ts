export const CONTRACT_ADDRESSES = {
    orgFactoryProxy: '0x5E4319abc25a71b0bA71dFdCA907e54Feb870944',
    orgRegistry: '0xed9F265fD6c7ee4CC5c3Be688C808D93e177085D',
    orgAttendanceLite: '0x5084696b974c89d078afe287EA96963a3CFa640F',
    attendanceNFTLite: '0xdC4f739b9a1ADFDDd8562c7c9C3432AF620835EB'
  } as const;

// Export individual addresses for easier imports
export const ORG_FACTORY_PROXY_ADDRESS = CONTRACT_ADDRESSES.orgFactoryProxy;
export const ORG_REGISTRY_ADDRESS = CONTRACT_ADDRESSES.orgRegistry;
export const ORG_ATTENDANCE_LITE_ADDRESS = CONTRACT_ADDRESSES.orgAttendanceLite;
export const ATTENDANCE_NFT_LITE_ADDRESS = CONTRACT_ADDRESSES.attendanceNFTLite;