server <- function(input, output, session) {
  # Interactive Side Panel ------------------------------------------------------------------------------
  # Summary Panel  //////////////////////////////////////////////////////////////////////////
  output$std = renderUI(
    selectInput(inputId = "std_filter", label = "Data with in X std",
                choices = c("ALL", 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4))
  )
  output$time_range_1 = renderUI(
    sliderInput(
      inputId = "time_slider_1",
      label = "",
      min = min(raw_df$created_at_date),
      max = max(raw_df$created_at_date),
      value = c(min(raw_df$created_at_date), max(raw_df$created_at_date)),
      step = 1
    )
  )
  
  output$exclude_shop_id = renderUI(
    textInput(inputId = "exclude_shop_id_input", label = "Exclude Shop ID",
              value = "", width = "100%", placeholder = "53, 92, 44 ...")
  )
  # Trend Panel  //////////////////////////////////////////////////////////////////////////
  output$user_id = renderUI(
    textInput(inputId = "user_id_input", label = "User ID",
              value = "", width = "100%", placeholder = "914, 788, 848 ...")
  )
  
  output$shop_id = renderUI(
    textInput(inputId = "shop_id_input", label = "Shop ID",
              value = "83", width = "100%", placeholder = "53, 92, 44 ...")
  )
  
  output$payment = renderUI(
    selectInput(inputId = "payment_input", label = "Payment Filter",
                choices = c("ALL", unique(raw_df$payment_method)))
  )
  
  output$time_range_2 = renderUI(
    sliderInput(
      inputId = "time_slider_2",
      label = "Time Filter",
      min = min(raw_df$created_at_date),
      max = max(raw_df$created_at_date),
      value = c(min(raw_df$created_at_date), max(raw_df$created_at_date)),
      step = 1,
      timeFormat = '%Y-%m-%d'
    )
  )
  
  # Statistics Panel //////////////////////////////////////////////////////////////////////////
  output$user_id2 = renderUI(
    textInput(inputId = "user_id_input2", label = "User ID",
              value = "", width = "100%", placeholder = "914, 788, 848 ...")
  )
  output$shop_id2 = renderUI(
    textInput(inputId = "shop_id_input2", label = "Shop ID",
              value = "83", width = "100%", placeholder = "53, 92, 44 ...")
  )
  
  output$payment2 = renderUI(
    selectInput(inputId = "payment_input2", label = "Payment Filter",
                choices = c("ALL", unique(raw_df$payment_method)))
  )
  
  output$time_range_3 = renderUI(
    sliderInput(
      inputId = "time_slider_3",
      label = "Time Filter",
      min = min(raw_df$created_at_date),
      max = max(raw_df$created_at_date),
      value = c(min(raw_df$created_at_date), max(raw_df$created_at_date)),
      step = 1,
      timeFormat = '%Y-%m-%d'
    )
  )
  
  # SUMMARY (BOXPLOT) PANEL CONSTRUCTION ----------------------------------------------------------------
  # Box Plot Summary
  summary_dataset <- reactive({ execute_safely(
    filter_dataset_summary(raw_df, input$std_filter, input$time_slider_1, input$exclude_shop_id_input)
    )
  })
  
  output$boxplot_panel <- renderPlotly({
    plot_ly(summary_dataset(), 
            type = "box", 
            x = ~created_at_date, y = ~order_amount, 
            text = paste0("<b> order_id: </b>", summary_dataset()$order_id, "<br/>",
                          "<b> shop_id: </b>", summary_dataset()$shop_id, "<br/>",
                          "<b> user_id: </b>", summary_dataset()$user_id, "<br/>",
                          "<b> total_items: </b>", summary_dataset()$total_items, "<br/>",
                          "<b> payment_method: </b>", summary_dataset()$payment_method, "<br/>",
                          "<b> created_at: </b>", summary_dataset()$created_at, "<br/>"
                          ),
            hoverinfo = "y", height = 810, width = 1440) %>%
      layout(title = 'Transaction Summary Box Plots', plot_bgcolor = "#e5ecf6", xaxis = list(title = 'Time'), 
             yaxis = list(title = 'Order Amount in Dollars')) %>%
      onRender(addHoverBehavior)
  })
  
  output$hover_info <- renderUI({
    if(isTRUE(input[["hovering"]])){
      style <- paste0("left: ", input[["left_px"]] + 100, "px;", # 4 = border-width after
                      "top: ", input[["top_px"]] - 60, "px;") # 24 = line-height/2 * number of lines; 2 = padding; 1 = border thickness
      div(
        class = "arrow_box", style = style,
        p(HTML(input$dtext, 
               "<b> value: </b>", formatC(input$dy)), 
          style="margin: 0; padding: 2px; line-height: 16px;")
      )
    }
  })
  
  # TIME SERIES PANEL CONSTRUCTION ----------------------------------------------------------------------
  trend_dataset <- reactive({ execute_safely(
    filter_dataset_trend(raw_df,input$user_id_input, input$shop_id_input, input$payment_input, input$time_slider_2)
    )
  })
  output$trend_panel <- renderPlotly({
    ggplotly(ggplot(trend_dataset(),
                    aes(x = created_at_date, y = total_items, color = user_id:shop_id, size = order_amount,
                        extra1 = payment_method, extra2 = created_at_time)) + 
               geom_point(alpha = 0.5) + 
               scale_size_continuous(range=c(1,log(max(trend_dataset()$order_amount, base = 2)))) +
               theme(legend.position = "none",
                     panel.background = element_rect(fill = "#e5ecf6", color = "white")) +
               labs(x = "Time in Day",
                    y = "Total items per transaction",
                    title = "Information of Transactions with User, Shop, Price, Amount and Time")
               , height = 810, width = 1440
             )
  })
  
  # STATISTICS PANEL CONSTRUCTION -----------------------------------------------------------------------
  
  # Upper Right: Transaction with value per transaction
  # Upper left: Transaction with value per item
  statistics_dataset <- reactive({ execute_safely(
    filter_dataset_statistics(raw_df,input$user_id_input2, input$shop_id_input2, "ALL", input$time_slider_3)
    )
  })
  
  output$statistics_transaction <- renderPlotly({
    df <- statistics_dataset() %>% group_by(shop_id, user_id, created_at_date) %>%
      summarize(mean_amount = mean(order_amount))
    
    ggplot(df, aes(x = created_at_date, y = mean_amount)) +
      geom_line(size = 1) + 
      theme(legend.position = "none",
            panel.background = element_rect(fill = "#e5ecf6", color = "white")) +
      labs(x = "Time in Day",
           y = "Value per Transaction",
           title = "Time Series of Transaction Value")
  })
  
  output$statistics_item <- renderPlotly({
    df <- statistics_dataset() %>% group_by(shop_id, user_id, created_at_date) %>%
      summarize(mean_amount = mean(price_per_item))
    
    ggplotly(ggplot(df, aes(x = created_at_date, y = mean_amount)) +
               geom_line(size = 1) + 
               theme(legend.position = "none",
                     panel.background = element_rect(fill = "#e5ecf6", color = "white")) +
               labs(x = "Time in Day",
                    y = "Value per Item",
                    title = "Time Series of Item Value"))
  })
  
  output$statistics_table <- renderDataTable(data.table(statistics_dataset()), options = list(pageLength = 10))
  
  # Report the metrics by transaction
  output$report1 <- renderInfoBox(infoBox("Maximum Value Over Order",
                                          max(statistics_dataset()$order_amount),width = 3, icon = icon("area-chart")))
  output$report2 <- renderInfoBox(infoBox("Average Value Over Order",
                                          mean(statistics_dataset()$order_amount),width = 3, icon = icon("area-chart")))
  output$report3 <- renderInfoBox(infoBox("Median Value Over Order",
                                          median(statistics_dataset()$order_amount),width = 3, icon = icon("area-chart")))
  # Report the metrics by item
  output$report4 <- renderInfoBox(infoBox("Maximum Value Over Item",max(statistics_dataset()$price_per_item),width = 3))
  output$report5 <- renderInfoBox(infoBox("Average Value Over Item",mean(statistics_dataset()$price_per_item),width = 3))
  output$report6 <- renderInfoBox(infoBox("Median Value Over Item",median(statistics_dataset()$price_per_item),width = 3))
  
  # Lower Right
  # The filtered Data Table
  
  # RESUME TABLE CONSTRUCTION ---------------------------------------------------------------------------
  
  # DYNAMIC RENDER RULES --------------------------------------------------------------------------------
  
  observeEvent("", {
    show("summary_panel")
    hide("trend_panel")
    hide("statistics_panel")
    hide("resume_panel")
  }, once = TRUE)
  observeEvent(input$summary, {
    show("summary_panel")
    hide("trend_panel")
    hide("statistics_panel")
    hide("resume_panel")
  })
  observeEvent(input$trend, {
    hide("summary_panel")
    show("trend_panel")
    hide("statistics_panel")
    hide("resume_panel")
  })
  observeEvent(input$statistics, {
    hide("summary_panel")
    hide("trend_panel")
    show("statistics_panel")
    hide("resume_panel")
  })
  observeEvent(input$resume, {
    hide("summary_panel")
    hide("trend_panel")
    hide("statistics_panel")
    show("resume_panel")
  })
}