source('dependencies.R')

# load all packages
lapply(required_packages, require, character.only = TRUE)

# LOAD THE REQUIRED DATASET -------------------------------------------------------

raw_df <- read.xlsx(file.path(getwd(), "dataset.xlsx"), sheetIndex = 1)
raw_df$created_at_date <- as.Date(raw_df$created_at)
raw_df$created_at_time <- strftime(raw_df$created_at, format="%H:%M:%S")
raw_df$user_id <- as.factor(raw_df$user_id)
raw_df$shop_id <- as.factor(raw_df$shop_id)

# DATA HELPER FUNCTION ------------------------------------------------------------
filter_helper_id <- function(parent, child, in_ops = T) {
  condition = rep(T, length(parent))
  if(length(child) > 0) {
    for(index in c(1:length(parent))) {
      condition[index] = ifelse(in_ops, (parent[index] %in% child), !(parent[index] %in% child))
    }
  }
  return(condition)
}

filter_helper_payment <- function(parent, child) {
  condition = rep(T, length(parent))
  if(child != "ALL") {
    for(index in c(1:length(parent))) {
      condition[index] = (parent[index] == child)
    }
  }
  return(condition)
}

filter_helper_std <- function(parent, child, std) {
  condition = rep(T, length(parent))
  if(std != "ALL") {
    for(index in c(1:length(parent))) {
      condition[index] = (parent[index] <= as.numeric(std) * child)
    }
  }
  return(condition)
}

filter_dataset_summary <- function(df, std, time_range, exclude_shop_id) {
  if(is.null(time_range)|is.null(std)|is.null(exclude_shop_id)) {
    time_range = c("2017-03-01", "2017-03-31")
    std = "ALL"
    exclude_shop_id = ""
  }
  exclude_shop_id = sapply(unlist(strsplit(exclude_shop_id, ",")), as.numeric)
  
  df = df %>% 
    filter(created_at_date >= time_range[1],
           created_at_date <= time_range[2],
           filter_helper_id(shop_id, exclude_shop_id, in_ops = F)
           )
  
  sd_value = sd(df$order_amount)
  mean_value = mean(df$order_amount)
  result = df %>%
    filter(filter_helper_std(abs(order_amount - mean_value), sd_value, std))
  return(result)
}

filter_dataset_trend <- function(df, userid, shopid, payment, time_range, rm_stop = F) {
  if(is.null(userid)|is.null(shopid)|is.null(payment)|is.null(time_range)) {
    time_range = c("2017-03-01", "2017-03-31")
    payment = "ALL"
    shopid = "83"
    userid = ""
  }
  
  result = NULL
  if(userid != "" | shopid != "" | rm_stop) {
    userid = sapply(unlist(strsplit(userid, ",")), as.numeric)
    shopid = sapply(unlist(strsplit(shopid, ",")), as.numeric)
    
    result <- df %>% filter(filter_helper_id(user_id, userid),
                            filter_helper_id(shop_id, shopid),
                            filter_helper_payment(payment_method, payment),
                            created_at_date >= time_range[1],
                            created_at_date <= time_range[2]
                            )
    return(result)
  }else{
    stop("Dataset too large, apply filters on the left side panel to reduce observations")
  }
}

filter_dataset_statistics <- function(df, userid, shopid, payment, time_range) {
  filtered_df = filter_dataset_trend(df, userid, shopid, payment, time_range, rm_stop = T)
  result <- filtered_df %>%
    mutate(price_per_item = order_amount / total_items) %>%
    select(shop_id, user_id, order_amount, price_per_item, created_at_date, created_at_time)
}
# PLOTLY BOXPLOT HOVER FUNCTION ---------------------------------------------------

addHoverBehavior <- c(
  "function(el, x){",
  "  el.on('plotly_hover', function(data) {",
  "    if(data.points.length==1){",
  "      $('.hovertext').hide();",
  "      Shiny.setInputValue('hovering', true);",
  "      var d = data.points[0];",
  "      Shiny.setInputValue('left_px', d.xaxis.d2p(d.x) + d.xaxis._offset);",
  "      Shiny.setInputValue('top_px', d.yaxis.l2p(d.y) + d.yaxis._offset);",
  "      Shiny.setInputValue('dy', d.y);",
  "      Shiny.setInputValue('dtext', d.text);",
  "    }",
  "  });",
  "  el.on('plotly_unhover', function(data) {",
  "    Shiny.setInputValue('hovering', false);",
  "  });",
  "}")