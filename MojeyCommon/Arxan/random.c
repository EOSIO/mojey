//
//  random.c
//  MojeyMessage
//
//  Created by Todd Bowden on 10/23/19.
//  Copyright © 2020 Mojey. All rights reserved.
//

#include "random.h"
#import <Security/Security.h>

int random_data(const unsigned int data_size, unsigned char * const data) {
    return SecRandomCopyBytes(kSecRandomDefault, data_size, data);
}
