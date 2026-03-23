package com.mvc.app.config;

import javax.sql.DataSource;

import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.google.genai.GoogleGenAiEmbeddingConnectionDetails;
import org.springframework.ai.google.genai.text.GoogleGenAiTextEmbeddingModel;
import org.springframework.ai.google.genai.text.GoogleGenAiTextEmbeddingOptions;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.pgvector.PgVectorStore;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class EmbeddingConfig {

    @Value("${spring.ai.google.genai.api-key}")
    private String apiKey;

    @Value("${pg.datasource.url}")
    private String pgUrl;

    @Value("${pg.datasource.username}")
    private String pgUsername;

    @Value("${pg.datasource.password}")
    private String pgPassword;

    @Bean(name = "pgDataSource")
    public DataSource pgDataSource() {
        return DataSourceBuilder.create()
                .url(pgUrl)
                .username(pgUsername)
                .password(pgPassword)
                .driverClassName("org.postgresql.Driver")
                .build();
    }

    @Bean
    public EmbeddingModel embeddingModel() {
        GoogleGenAiEmbeddingConnectionDetails connectionDetails =
            GoogleGenAiEmbeddingConnectionDetails.builder()
                .apiKey(apiKey)
                .build();
        GoogleGenAiTextEmbeddingOptions options =
            GoogleGenAiTextEmbeddingOptions.builder()
                .model("models/gemini-embedding-001")
                .dimensions(768)
                .build();
        return new GoogleGenAiTextEmbeddingModel(connectionDetails, options);
    }

    @Bean(name = "pgVectorStore")
    public VectorStore vectorStore(EmbeddingModel embeddingModel) {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(pgDataSource());
        return PgVectorStore.builder(jdbcTemplate, embeddingModel)
                .dimensions(768)
                .distanceType(PgVectorStore.PgDistanceType.COSINE_DISTANCE)
                .indexType(PgVectorStore.PgIndexType.HNSW)
                .vectorTableName("qna_bot")
                .initializeSchema(true)
                .build();
    }
}