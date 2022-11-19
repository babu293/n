set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 50
set val(nn) 3
set val(rp) DSDV

set ns [new Simulator]
set tf [open output.tr w]
$ns trace-all $tf
set tf1 [open output.nam w]
$ns namtrace-all-wireless $tf1 100 100

set topo [new Topography]
$topo load_flatgrid 100 100

create-god $val(nn)
$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace OFF \
-macTrace OFF \
-movementTrace OFF

for {set i 0} {$i < 3} {incr i} {
    set node($i) [$ns node];
    $ns initial_node_pos $node($i) 10
    $node($i) set Y_ 50.0
    $node($i) set Z_ 0.0
}

$node(0) set X_ 25.0
$node(1) set X_ 50.0
$node(2) set X_ 65.0


set tcp1 [new Agent/TCP]
$ns attach-agent $node(0) $tcp1
set ftp [new Application/FTP]
$ftp attach-agent $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $node(2) $sink1
$ns connect $tcp1 $sink1
$ns at 10.0 "$node(1) setdest 50.0 90.0 0.0"
$ns at 50.0 "$node(1) setdest 50.0 10.0 0.0"
$ns at 0.5 "$ftp start"
$ns at 1000 "$ftp stop"
$ns at 1000 "finish"

proc finish {} {
    global ns tf tf1
    $ns flush-trace
    close $tf
    exec nam output.nam &
    exit 0
}

$ns run
