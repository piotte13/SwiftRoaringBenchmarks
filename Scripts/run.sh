#!/bin/bash
cd "$(dirname "$0")" || exit
echo "Building..."
cd ..
swift build  -Xcc -march=native  --configuration release

echo "Running SwiftRoaringBenchmarks..."
./.build/x86_64-unknown-linux/release/SwiftRoaringBenchmarks

echo "Running CRoaringBenchmarks..."
./.build/x86_64-unknown-linux/release/CRoaringBenchmarks

echo "Running SwiftSetBenchmarks..."
./.build/x86_64-unknown-linux/release/SwiftSetBenchmarks

echo "Running SwiftBitsetBenchmarks..."
./.build/x86_64-unknown-linux/release/SwiftBitsetBenchmarks

cd "$(dirname "$0")" || exit
chmod +x ./plotting.py
pip install py-cpuinfo
pip install plotly
python ./plotting.py
