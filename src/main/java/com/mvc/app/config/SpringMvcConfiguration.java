package com.mvc.app.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class SpringMvcConfiguration implements WebMvcConfigurer {
	@Value("${file.upload-root}")
	private String uploadRoot;
	
	@Override
	public void addResourceHandlers(ResourceHandlerRegistry registry) {

	    registry.addResourceHandler("/uploads/**")
	            .addResourceLocations("file:" + uploadRoot + "/");
	}
}
