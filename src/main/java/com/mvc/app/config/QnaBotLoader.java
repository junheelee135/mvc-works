package com.mvc.app.config;

import java.nio.file.Files;
import java.util.List;
import java.util.stream.Collectors;

import javax.sql.DataSource;

import org.springframework.ai.document.Document;
import org.springframework.ai.transformer.splitter.TextSplitter;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.core.simple.JdbcClient;

import jakarta.annotation.PostConstruct;

@Configuration(proxyBeanMethods = false)
public class QnaBotLoader {

    private final VectorStore vectorStore;
    private final JdbcClient jdbcClient;

    @Value("classpath:data.txt")
    private Resource resource;

    public QnaBotLoader(@Qualifier("pgVectorStore") VectorStore vectorStore,
                        @Qualifier("pgDataSource") DataSource pgDataSource) {
        this.vectorStore = vectorStore;
        this.jdbcClient = JdbcClient.create(pgDataSource);
    }

    @PostConstruct
    public void init() throws Exception 
    {Integer count = jdbcClient.sql("select count(*) from qna_bot")
                .query(Integer.class).single();
        if (count == 0) {
            List<Document> documents = Files.lines(resource.getFile().toPath())
                    .map(Document::new)
                    .collect(Collectors.toList());
            TextSplitter textSplitter = new TokenTextSplitter();
            for (Document document : documents) {
                List<Document> splittedDocs = textSplitter.split(document);
                vectorStore.add(splittedDocs);
                Thread.sleep(1000);
            }
        }
    }
}