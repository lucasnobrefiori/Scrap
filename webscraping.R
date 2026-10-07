library(rvest)
library(dplyr)
library(stringr)
library(purrr)

# 1. Gera as URLs das 50 páginas
paginas <- paste0("https://books.toscrape.com/catalogue/page-", 1:50, ".html")

# ====================================================
# (RECOLHER OS LINKS DE TODOS OS LIVROS)
# ====================================================
urls_livros <- map(paginas, function(pagina_url) {
  message("Baixando links de: ", pagina_url)
  
  page <- read_html(pagina_url)
  
  hrefs <- html_elements(page, ".product_pod") %>% 
    html_element("h3 a") %>% 
    html_attr("href") %>% 
    unique()
  
  # Limpa e constrói a URL 
  links_completos <- paste0("https://books.toscrape.com/catalogue/", str_remove_all(hrefs, "^(\\.\\./)+"))
  
  return(links_completos)
})

# Unifica a lista num vetor único de links
urls_livros <- Reduce(c, urls_livros)

# ====================================================
#  (TESTAR NO PRIMEIRO LIVRO)
# ====================================================
url <- urls_livros[1]
print(url) # Agora deve exibir: "https://books.toscrape.com/catalogue/a-light-in-the-attic_1000/index.html"

# Lê a página do primeiro livro
page <- read_html(url)

titulo <- html_elements(page, ".product_main") %>% html_element("h1") %>% html_text()
price  <- html_elements(page, ".product_main") %>% html_element(".price_color") %>% html_text()
Stock  <- html_elements(page, ".product_main") %>% html_element(".instock") %>% html_text() %>% str_trim()
rating <- html_elements(page, ".product_main") %>% html_elements(".star-rating") %>% html_attr("class") %>% str_remove("star-rating") %>% str_trim()

#######################


tabela_final <- map_df(urls_livros[1:50], function(url_livro) {
  
  page <- read_html(url_livro)
  
  tibble(
    Titulo    = html_elements(page, ".product_main") %>% html_element("h1") %>% html_text(),
    Preco     = html_elements(page, ".product_main") %>% html_element(".price_color") %>% html_text(),
    Estoque   = html_elements(page, ".product_main") %>% html_element(".instock") %>% html_text() %>% str_trim(),
    Avaliacao = html_elements(page, ".product_main") %>% html_elements(".star-rating") %>% html_attr("class") %>% str_remove("star-rating") %>% str_trim(),
    Link      = url_livro
  )
})

print(tabela_final)
