package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

@RestController
@SpringBootApplication
@EnableScheduling
public class DemoApplication {

	private static String FILE_PATH;

	@Value("${dynamic.path}")
	public void setKey(String value) {
		FILE_PATH = value;
	}

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}

	@Scheduled(fixedRate=1000)
	public void filecheck() throws IOException {
		List<String> str = Files.readAllLines(Paths.get(FILE_PATH));
		System.out.println(str);
	}

	@RequestMapping(method = RequestMethod.GET, path = "/")
	public String index() throws IOException {
		List<String> str = Files.readAllLines(Paths.get(FILE_PATH));
		System.out.println(str);

		return "<h1>AWS</h1>"
		.concat("<h2>" + str.get(0) + "</h2>")
		.concat("<h2>" + str.get(1) + "</h2>");
	}
}