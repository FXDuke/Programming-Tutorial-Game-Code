export type UIPackedMessage = {
	content: string,
	duration: number?,
	responses: {string}?,
	sender: string?,
};

return function(content: string, duration: number?, responses: {string}?, sender: string?): UIPackedMessage
	assert(content, "Content must be provided to create a message.");
	
	return {
		content = content,
		duration = duration or -1,
		responses = responses or {},
		sender = sender or ""
	};
end
