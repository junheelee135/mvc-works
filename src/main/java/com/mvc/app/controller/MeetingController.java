  package com.mvc.app.controller;

  import org.springframework.stereotype.Controller;
  import org.springframework.web.bind.annotation.GetMapping;
  import org.springframework.web.bind.annotation.RequestMapping;

  @Controller
  @RequestMapping("/meeting")
  public class MeetingController {

      @GetMapping("/room")
      public String room() {
          return "meeting/room";
      }

      @GetMapping("/reserve")
      public String reserve() {
          return "meeting/reserve";
      }

      @GetMapping("/mylist")
      public String mylist() {
          return "meeting/mylist";
      }
  }
