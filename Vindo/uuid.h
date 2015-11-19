//
//  uuid.h
//  Vindo
//
//  Created by Dubois, Theodore Alexander on 11/18/15.
//  Copyright © 2015 Theodore Dubois. All rights reserved.
//

#include <IOKit/IOKitLib.h>
#include <IOKit/network/IOEthernetInterface.h>
#include <IOKit/network/IONetworkInterface.h>
#include <IOKit/network/IOEthernetController.h>

kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices);
kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize);
