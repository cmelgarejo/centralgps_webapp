$(document).ready(function(){
 // $("form").on("submit", function(event) {
 //   event.preventDefault();
 //   $that = this;
 //   $.ajax({
 //     url: $that.getAttribute('action'),
 //     type: "POST",
 //     contentType:"application/json;charset=utf-8"
 //     data: $('form').serialize(), success: function(data) {
 //       console.log(data.result)
 //     }
 //   });
 // });

  (function(){
     Waves.attach('.btn', ['waves-button', 'waves-float']);
     Waves.init();
  })();

  if($('.fg-line')[0]) {
     $('body').on('focus', '.form-control', function(){
         $(this).closest('.fg-line').addClass('fg-toggled');
     })

     $('body').on('blur', '.form-control', function(){
         var p = $(this).closest('.form-group');
         var i = p.find('.form-control').val();

         if (p.hasClass('fg-float')) {
             if (i.length == 0) {
                 $(this).closest('.fg-line').removeClass('fg-toggled');
             }
         }
         else {
             $(this).closest('.fg-line').removeClass('fg-toggled');
         }
     });
  }

  if($('.fg-float')[0]) {
     $('.fg-float .form-control').each(function(){
         var x = $(this).val();
         if (!x.length == 0) {
             $(this).closest('.fg-line').addClass('fg-toggled');
         }
     });
  }
});
