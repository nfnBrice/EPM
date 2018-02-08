$ deletePortfolio(portfolioToDelete)() 
{
    $.ajax(
    {
        url: '/deletePortfolio'+ portfolioToDelete,
        data: portfolioToDelete,
        type: 'POST',

        success: deletePortfolio(response) {
            console.log(response);
        },
        error: deletePortfolio(error) {
            console.log(error);
        }
    });
}
