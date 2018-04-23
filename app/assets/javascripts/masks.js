jQuery(function($){
	//MASCARAS PARA O CONTAS Á PAGAR E RECEBER

   //valores no cadastro de produtos
   $("#cost_value").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#cost_sale").maskMoney({symbol:"R$",decimal:".",thousands:""});
   //-------------------------------

   //valores no cadastro de taxas
   $("#pis").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#icms").maskMoney({symbol:"R$",decimal:".",thousands:""});
   //-------------------------------

   //-------------------------------

   $("#phone").mask("(99) 9999-9999",{placeholder:""});
   $("#phone1").mask("(99) 9999-9999",{placeholder:""});
   $("#celphone").mask("(99)99999-9999", {placeholder:""});
   $("#cep").mask("99999-999",{placeholder:""});
   $("#cpf").mask("999.999.999-99",{placeholder:" "});
   $("#cnpj").mask("99.999.999/9999-99",{placeholder:" "});
   $("#ie").mask("999.999.999.999",{placeholder:""});
   //Faz a mascara de moeda do Brasil
   //maskMoney({symbol:"R$",decimal:",",thousands:"."})
   $("#real").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#placa").mask("aaa9999",{placeholder:""});

   $("#total_geral").mask("99.999.999/9999-99",{placeholder:" "});

  $("#r1").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#r2").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#r3").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#r4").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#r5").maskMoney({symbol:"R$",decimal:".",thousands:""});});

   $("#total_geral").mask("99.999.999/9999-99",{placeholder:" "});


   // para digitar somente numeros INUTILIZAÇÃO NFE
   $(document).ready(function () {
  //called when key is pressed in textbox
  $("#serie").keypress(function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
        //display error message
        $("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
});

   $(document).ready(function () {
  //called when key is pressed in textbox
  $("#num-ini").keypress(function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
        //display error message
        $("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
});

   $(document).ready(function () {
  //called when key is pressed in textbox
  $("#num-fin").keypress(function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
        //display error message
        $("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
});

// para digitar somente numeros QUANTIDADE
$(document).ready(function () {
//called when key is pressed in textbox
$("#quant").keypress(function (e) {
	//if the letter is not digit then display error and don't type anything
	if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
		 //display error message
		 $("#errmsg").html("Digits Only").show().fadeOut("slow");
						return false;
 }
});
});


   // para digitar somente numeros QUANTIDADE
   $(document).ready(function () {
  //called when key is pressed in textbox
  $("#qnt").keypress(function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
        //display error message
        $("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
});

   // para digitar somente numeros Peso bruto
   $(document).ready(function () {
  //called when key is pressed in textbox
  $("#pliq").keypress(function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && e.which != 46 && (e.which < 48 || e.which > 57)) {
        //display error message
        $("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
});

   // para digitar somente numeros peso liquido
   $(document).ready(function () {
  //called when key is pressed in textbox
  $("#pbruto").keypress(function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && e.which != 46 && (e.which < 48 || e.which > 57)) {
        //display error message
        $("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
});

  // para digitar somente numeros NCM
   $(document).ready(function () {
  //called when key is pressed in textbox
  $("#ncm").keypress(function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
        //display error message
        $("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
});

// para digitar somente numeros ICMS
   $(document).ready(function () {
  //called when key is pressed in textbox
  $("#icms_trib").keypress(function (e) {
     //if the letter is not digit then display error and don't type anything
     if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
        //display error message
        $("#errmsg").html("Digits Only").show().fadeOut("slow");
               return false;
    }
   });
});

   //deixar tudo em letra maiuscula
   //$(document).ready(function() {
   //$("input").keyup(function(){
   // $(this).val($(this).val().toUpperCase());
   //	});
   //	});

	 //PARA ATIVAR O ENTER E IR PARA O PROXIMO CAMPO EM TODA A APLICAÇÃO
			$(document).ready(function () {
	 $('body').on('keydown', 'input, select, textarea', function(e) {
	 var self = $(this)
		 , form = self.parents('form:eq(0)')
		 , focusable
		 , next
		 , prev
		 ;

	 if (e.shiftKey) {
		if (e.keyCode == 13) {
				focusable =   form.find('input,a,select,button,textarea').filter(':visible');
				prev = focusable.eq(focusable.index(this)-1);

				if (prev.length) {
					 prev.focus();
				} else {
					 form.submit();
			 }
		 }
	 }
		 else
	 if (e.keyCode == 13) {
			 focusable = form.find('input,a,select,button,textarea').filter(':visible');
			 next = focusable.eq(focusable.index(this)+1);
			 if (next.length) {
					 next.focus();
			 } else {
					 form.submit();
			 }
			 return false;
	 }
	 });
		 });
