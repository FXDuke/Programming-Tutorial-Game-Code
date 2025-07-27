export type UIPackedMessage = {
	content: string,
	duration: number?,
};

return function(content: string, duration: number?): UIPackedMessage
	assert(content, "Content must be provided to create a message.");
	
	return {
		content = content,
		duration = duration or -1,
	};
end
