extends SceneTree
# Maglev Cycle 1 — Godot Client Gateway Handshake
# Pass criteria (per multiplayer-fabric-manuals/decisions/20260506-maglev-cycle-1-gateway-handshake.md):
#   1. Establish WebTransport/QUIC to multiplayer-fabric-gateway on UDP 443
#   2. Receive one datagram (the gateway's "pong" reply per router.ex:55)
#   3. Exit cleanly, no orphaned process
#
# Run:
#   godot --headless --script /tmp/c1-handshake.gd

const HOST := "gateway.chibifire.com"
const PORT := 443
const PATH := "/"
const TIMEOUT_MS := 10000

var peer: WebTransportPeer
var sent := false
var t0 := 0
var ping_id := ""

func _init() -> void:
	peer = WebTransportPeer.new()
	var err := peer.create_client(HOST, PORT, PATH)
	if err != OK:
		printerr("[C1 FAIL] create_client error: ", err)
		quit(1)
		return
	t0 = Time.get_ticks_msec()
	ping_id = "c1-" + str(Time.get_unix_time_from_system())
	print("[C1] connecting to ", HOST, ":", PORT, PATH, " ...")

func _process(_delta: float) -> bool:
	if not peer:
		return false
	peer.poll()
	var state: int = peer.get_connection_status()

	if Time.get_ticks_msec() - t0 > TIMEOUT_MS:
		printerr("[C1 FAIL] timeout — last connection_status=", state)
		peer.close()
		quit(1)
		return false

	if state == MultiplayerPeer.CONNECTION_CONNECTED and not sent:
		sent = true
		print("[C1] WebTransport/QUIC connected — TLS/HTTP3 handshake OK")
		var msg := JSON.stringify({"action": "ping", "id": ping_id, "v": 1})
		peer.put_packet(msg.to_utf8_buffer())
		print("[C1] sent ping datagram: ", msg)

	if state == MultiplayerPeer.CONNECTION_CONNECTED and sent:
		while peer.get_available_packet_count() > 0:
			var reply: String = peer.get_packet().get_string_from_utf8()
			print("[C1] received datagram: ", reply)
			if reply.find("pong") >= 0 or reply == "pong":
				print("[C1 PASS] gateway handshake + datagram round-trip verified")
				peer.close()
				quit(0)
			else:
				printerr("[C1 FAIL] unexpected datagram payload: ", reply)
				peer.close()
				quit(1)
			return false

	if state == MultiplayerPeer.CONNECTION_DISCONNECTED and sent:
		printerr("[C1 FAIL] disconnected before reply received")
		quit(1)
	return false
