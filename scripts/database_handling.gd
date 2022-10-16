extends CanvasLayer

var an_url = "https://devweb3000.cis.strath.ac.uk/~xpb17212/godot_communication.php" 
# "sftp://cafe.cis.strath.ac.uk/"

func _ready():
	add_request_queue({"url":an_url,"header":["ContentType: logs/json","Path: TEST_ID/test1.txt"],
	"query":"1a,b,c,d,e\n","ssl":true})
	
	add_request_queue({"url":an_url,"header":["ContentType: logs/json","Path: TEST_ID/test1.txt"],
	"query":"2a,b,c,d,e\n","ssl":true})
	add_request_queue({"url":an_url,"header":["ContentType: logs/json","Path: TEST_ID/test2.txt"],
	"query":"3a,b,c,d,e\n","ssl":true})
	add_request_queue({"url":an_url,"header":["ContentType: logs/json","Path: TEST_ID/test3.txt"],
	"query":"4a,b,c,d,e\n","ssl":true})
	
	send_oldest_request()

var request_queue = []
func add_request_queue(param_dict):
	request_queue.append(param_dict)

func send_oldest_request():
	if request_queue.empty() == false:
		var to_send = request_queue[0]
		make_post_request(to_send["url"],to_send["header"],to_send["query"],to_send["ssl"])

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		request_queue.remove(0)
		if request_queue.empty() == false:
			send_oldest_request()

func make_post_request(url,headers,query, use_ssl):
	$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
	print("sending request...")
