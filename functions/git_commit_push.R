#' Commit and Push Changes to Git Repository
#'
#' This function commits all changes in the current Git repository and pushes 
#' them to the remote repository. The commit message can be specified as an 
#' argument.
#'
#' @param message A character string specifying the commit message. Default is "update".
#'
#' @return None. The function performs Git operations and outputs the results to the console.
#' @export
#'
#' @examples
#' # Commit and push with the default message
#' git_commit_push()
#'
#' # Commit and push with a custom message
#' git_commit_push("My custom commit message")

git_commit_push <- function(message = "update") {
  # Add all changes to staging
  system("git add .")
  
  # Commit with the provided message
  system(paste("git commit -m", shQuote(message)))
  
  # Push to the remote repository
  system("git push")
}
