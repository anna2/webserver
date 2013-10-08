#'socket' provides access to TCPServer and TCPSocket.
#TCPServer object is a factory for TCPSocket objects.
#Sockets are simply the endpoints of a two-way communication channel.
#TCP is a specific channel over which a socket may be implemented.
#Use this syntax: TCPServer.open(hostname, port)
#(Other channels besides TCP: Unix, UDP, others.)
require 'socket' 


def get_file_path(request_line)
	request_line = request_line.split(" ")
	path = request_line[1]
	ROOT + path
end


FILE_TYPES = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

def determine_content_type(request_line)
	file_path = get_file_path(request_line)
	type = file_path.split(".")[-1]
	FILE_TYPES[type]
end


#!!!Ask Dave about this part!!!
host = 'localhost'
port = 2345
ROOT = File.expand_path(File.join(File.dirname(__FILE__)))

#Create a TCPServer object to listen for incoming connections.
webserver = TCPServer.new(host, port)

#Create a loop to process incoming requests one at a time.
loop do

	#Create a new socket when the webserver accepts incoming communication.
	socket = webserver.accept

	#Read the first line of the incoming request
	request_line = socket.gets
	path = get_file_path(request_line)

	#Print incoming request and path for debugging purposes.
	STDERR.puts request_line
	STDERR.puts path

	#Make sure the file exists!
	if File.exists?(path)

		#The server tells the client the type and size of data that will be in the response.
		socket.print 	"HTTP/1.1 200 OK\r\n" +
						"Content-Type: #{determine_content_type(request_line)} \r\n" +
						"Content-Length: #{File.size?(path)}\r\n" +
						"Connection: close \r\n" 

		#A blank line must separate header and webpage content.
		#HTTP is whitespace sensitive.
		socket.print "\r\n"

		#Now print the contents of the file to the socket.
		page_content = File.read(path)
		socket.print page_content
	else
		socket.print "Error: No such file found."
	end

	#Close socket to end the communication between server and client.
	socket.close

end
