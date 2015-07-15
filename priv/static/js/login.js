$(document).ready(function(){

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
  //The form HAS to have an action.
  $("form").on("submit", function(event) {
   event.preventDefault();
   $that = this;
   $($that).find(':button:not(:disabled)').prop('disabled',true);
   Pace.track(function(){
    $.post($that.getAttribute('action'), $($that).serialize(),
     function(data, status, xhr) {
       $($that).find(':button:disabled').prop('disabled',false);
       $($that).find('#password').val("");
       if(data.status) {
         window.location = '/';//data.res;
       } else {
         if(data.msg == "nxdomain") data.msg = _err_msg;
         $($that).find('#alert').html("<div class='alert alert-danger alert-dismissible' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='X'><span aria-hidden='true'>×</span></button>"
           + data.msg + "</div>")
         $($that).find('#password').focus();
         //swal({title: "Error", type: "error", text: data.msg});
       }
     });
    });
   });

   $('#password,#username,#domain').change(function() {
     if (!$(this).parent().hasClass('fg-toggled')) {
       $(this).parent().addClass('fg-toggled');
     }
   });
});
