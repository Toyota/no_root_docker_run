# Copyright 2024 Toyota Motor Corporation.  All rights reserved. 
# ----
# Create secured directories inside the container to share with the host

import argparse
import os

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dirs', required=True, nargs="*", type=str, help='A list of making dir', default=[])
    args = parser.parse_args()

    # Host infromation
    if not args.dirs:
        print("No target")
    else:
        [os.makedirs(dirname, exist_ok=True) for dirname in args.dirs]
        pass
