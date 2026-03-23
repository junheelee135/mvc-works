package com.mvc.app.service;

import java.util.List;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import reactor.core.publisher.Flux;

@Service
public class QnaBotService {

    private final ChatClient chatClient;
    private final VectorStore vectorStore;

    public QnaBotService(ChatClient.Builder chatClientBuilder,
                         @Qualifier("pgVectorStore") VectorStore vectorStore) {
        this.chatClient = chatClientBuilder.build();
        this.vectorStore = vectorStore;
    }

    public Flux<String> generateAnswer(String question) {
        try {
        	List<Document> results = vectorStore.similaritySearch(
        	        SearchRequest.builder()
        	                .query(question)
        	                .similarityThreshold(0.3)  
        	                .topK(3)                   
        	                .build()
        	);
            System.out.println(results);
            String template = """
                    당신은 ERP 시스템 채팅봇입니다. 아래 컨텍스트를 바탕으로 직원의 질문에 정중하게 답변해 주십시오.
                    컨텍스트에 관련 정보가 있다면 반드시 그 내용을 바탕으로 답변하세요.
                    컨텍스트에 정보가 없을 때만 '해당 사항은 인사팀에 문의 바랍니다.'라고 답변하세요.
                    컨텍스트:
                    {context}
                    질문:
                    {question}
                    답변:
                    """;
            return chatClient.prompt()
                    .user(promptUserSpec -> promptUserSpec.text(template)
                            .param("context", results.toString())
                            .param("question", question))
                    .stream()
                    .content();
        } catch (Exception e) {
            return Flux.error(e);
        }
    }
}