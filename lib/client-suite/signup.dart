import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HoverWidget extends StatefulWidget {
  final Widget Function(bool) builder;
  const HoverWidget({super.key, required this.builder});
  @override State<HoverWidget> createState() => _HoverWidgetState();
}
class _HoverWidgetState extends State<HoverWidget>{
  bool h=false;
  @override Widget build(BuildContext c){
    return MouseRegion(
      onEnter:(_)=>setState(()=>h=true),
      onExit:(_)=>setState(()=>h=false),
      child:AnimatedContainer(duration:Duration(milliseconds:160),child:widget.builder(h))
    );
  }
}

class AuthService{
  AuthService._();
  static final instance=AuthService._();
  final _a=FirebaseAuth.instance;

  Future<UserCredential> signUpEmail({required String name,required String email,required String pass})async{
    final c=await _a.createUserWithEmailAndPassword(email:email,password:pass);
    await c.user?.updateDisplayName(name);
    return c;
  }
  Future<UserCredential> guest() async => await _a.signInAnonymously();

  Future<void> reset(String email) async => await _a.sendPasswordResetEmail(email:email);

  Future<void> googleRedirect() async{
    final p=GoogleAuthProvider();
    await FirebaseAuth.instance.signInWithRedirect(p);
  }
}

class ClientSignupPage extends StatefulWidget{
  const ClientSignupPage({super.key});
  @override State<ClientSignupPage> createState()=>_ClientSignupPageState();
}
class _ClientSignupPageState extends State<ClientSignupPage>{
  final _f=GlobalKey<FormState>();
  final _n=TextEditingController(),_e=TextEditingController(),_p=TextEditingController();
  bool load=false,show=false;

  static const double W=1050,LW=480,RW=320,DW=2,DH=220,DT=73;

  @override void initState(){super.initState();WidgetsBinding.instance.addPostFrameCallback((_)=>_afterRedirect());}
  Future<void> _afterRedirect()async{
    try{
      final r=await FirebaseAuth.instance.getRedirectResult();
      if(r.user!=null) _sn("Signed in as ${r.user!.email}");
    }catch(_){}
  }

  void _sn(String t){
    if(!mounted)return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t)));
  }

  Future<void> _signup() async{
    if(!_f.currentState!.validate())return;
    setState(()=>load=true);
    try{
      await AuthService.instance.signUpEmail(name:_n.text.trim(),email:_e.text.trim(),pass:_p.text);
      _sn("Account created");
    }catch(e){_sn("Signup failed");}
    if(mounted)setState(()=>load=false);
  }

  Future<void> _guest()async{
    setState(()=>load=true);
    try{await AuthService.instance.guest();_sn("Guest login");}
    catch(_){_sn("Guest failed");}
    if(mounted)setState(()=>load=false);
  }

  Future<void> _forgot()async{
    final c=TextEditingController(text:_e.text.trim());
    await showDialog(context:context,builder:(_)=>AlertDialog(
      title:Text("Reset Password"),
      content:TextField(controller:c,decoration:InputDecoration(labelText:"Email",border:OutlineInputBorder())),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context),child:Text("Cancel")),
        ElevatedButton(onPressed:()async{
          final m=c.text.trim();
          if(!m.contains("@")){_sn("Invalid email");return;}
          try{await AuthService.instance.reset(m);_sn("Reset email sent");}catch(_){_sn("Failed");}
          if(mounted)Navigator.pop(context);
        },child:Text("Send"))
      ],
    ));
  }

  InputDecoration dec(String h)=>InputDecoration(
    hintText:h,contentPadding:EdgeInsets.symmetric(horizontal:15,vertical:15),
    enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(6),borderSide:BorderSide(color:Colors.black,width:1.6)),
    focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(6),borderSide:BorderSide(color:Colors.black,width:1.6)),
  );

  Widget left(double w)=>SizedBox(width:w,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text("Full Name",style:TextStyle(fontSize:17,fontWeight:FontWeight.w600)),
    SizedBox(height:8),
    HoverWidget(builder:(h)=>AnimatedContainer(duration:Duration(milliseconds:140),decoration:BoxDecoration(boxShadow:h?[BoxShadow(color:Colors.black26,blurRadius:6)]:[]),child:
      TextFormField(controller:_n,validator:(v)=>v!.trim().isEmpty?"Enter name":null,decoration:dec("Enter your name")))),
    SizedBox(height:25),
    Text("Email",style:TextStyle(fontSize:17,fontWeight:FontWeight.w600)),
    SizedBox(height:8),
    HoverWidget(builder:(h)=>AnimatedContainer(duration:Duration(milliseconds:140),decoration:BoxDecoration(boxShadow:h?[BoxShadow(color:Colors.black26,blurRadius:6)]:[]),child:
      TextFormField(controller:_e,validator:(v)=>!v!.contains("@")?"Invalid email":null,decoration:dec("Enter your email")))),
    SizedBox(height:25),
    Text("Password",style:TextStyle(fontSize:17,fontWeight:FontWeight.w600)),
    SizedBox(height:8),
    HoverWidget(builder:(h)=>AnimatedContainer(duration:Duration(milliseconds:140),decoration:BoxDecoration(boxShadow:h?[BoxShadow(color:Colors.black26,blurRadius:6)]:[]),child:
      TextFormField(controller:_p,obscureText:!show,validator:(v)=>v!.length<6?"Min 6 chars":null,
        decoration:dec("Create password").copyWith(suffixIcon:IconButton(icon:Icon(show?Icons.visibility_off:Icons.visibility),onPressed:()=>setState(()=>show=!show)))))),
    SizedBox(height:25),
    HoverWidget(builder:(h)=>AnimatedOpacity(duration:Duration(milliseconds:160),opacity:h?0.85:1,child:
      SizedBox(height:50,width:double.infinity,child:
        ElevatedButton(onPressed:load?null:_signup,style:ElevatedButton.styleFrom(backgroundColor:Colors.black,foregroundColor:Colors.white,elevation:0),
          child:load?CircularProgressIndicator(color:Colors.white,strokeWidth:2):Text("Create Account",style:TextStyle(fontSize:16,fontWeight:FontWeight.w600)))))),
    SizedBox(height:12),
    Center(child:HoverWidget(builder:(h)=>GestureDetector(onTap:_forgot,child:RichText(text:TextSpan(
      text:"Already have an account? ",style:TextStyle(color:Colors.grey[700],fontSize:13),
      children:[TextSpan(text:"Login",style:TextStyle(color:Colors.black,fontWeight:FontWeight.w700,decoration:h?TextDecoration.underline:TextDecoration.none))]
    )))))
  ]));

  Widget btn({required Widget ic,required String t,required VoidCallback onTap})=>HoverWidget(builder:(h){
    final bg=h?Colors.black:Colors.white,fg=h?Colors.white:Colors.black;
    return AnimatedContainer(duration:Duration(milliseconds:160),child:SizedBox(height:48,width:double.infinity,
      child:OutlinedButton(onPressed:onTap,style:OutlinedButton.styleFrom(backgroundColor:bg,side:BorderSide(color:Colors.black,width:1.6),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(6))),
        child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
          ic is Icon?IconTheme(data:IconThemeData(color:fg,size:22),child:ic):ic,
          SizedBox(width:12),
          Text(t,style:TextStyle(color:fg,fontSize:17,fontWeight:FontWeight.w600))
        ]))));
  });

  Widget right(double w)=>SizedBox(width:w,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text("Continue With",style:GoogleFonts.montserrat(fontSize:20,fontWeight:FontWeight.w700)),
    SizedBox(height:25),
    btn(ic:Image.asset("assets/icons/google_logo.png",height:22),t:"Google",onTap:()async{
      setState(()=>load=true);
      try{await AuthService.instance.googleRedirect();_sn("Redirecting to Google...");}
      catch(_){_sn("Google sign-in failed to start");}
      if(mounted)setState(()=>load=false);
    }),
    SizedBox(height:16),
    btn(ic:Icon(Icons.person_outline),t:"Guest Mode",onTap:_guest)
  ]));

  Widget desk(double w){
    final full=w>=W;
    double lw=LW,rw=RW;
    if(!full){
      final a=w-40-40-DW;
      lw=a*0.58;
      rw=a*0.42;
    }
    return IntrinsicHeight(child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      SizedBox(width:lw,child:Form(key:_f,child:left(lw))),
      SizedBox(width:40),
      Padding(padding:EdgeInsets.only(top:DT),child:Container(width:DW,height:DH,color:Colors.black.withOpacity(.75))),
      SizedBox(width:40),
      Column(children:[SizedBox(height:DT),SizedBox(width:rw,child:right(rw))])
    ]));
  }

  Widget mob(double w){
    final lw=(w-40).clamp(280.0,LW);
    return Column(children:[
      Form(key:_f,child:left(lw)),
      SizedBox(height:20),
      SizedBox(width:120,child:Divider(color:Colors.black26)),
      SizedBox(height:20),
      right(w)
    ]);
  }

  @override Widget build(BuildContext c){
    return Scaffold(
      backgroundColor:Colors.white,
      body:SafeArea(child:LayoutBuilder(builder:(c,s){
        final w=s.maxWidth>=W?W:(s.maxWidth-24).clamp(320.0,W);
        final mobv=s.maxWidth<700;
        return Center(child:SingleChildScrollView(
          padding:EdgeInsets.symmetric(vertical:20),
          child:Stack(children:[
            Container(width:w,padding:EdgeInsets.fromLTRB(60,80,60,60),
              decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),
                boxShadow:[BoxShadow(color:Color.fromRGBO(0,0,0,.45),blurRadius:50)]),
              child:mobv?mob(w):desk(w)),
            Positioned(top:25,left:0,right:0,child:Center(child:
              Text("SIGN UP",style:GoogleFonts.montserrat(fontSize:34,fontWeight:FontWeight.w700,letterSpacing:1.4))))
          ])
        ));
      }))
    );
  }
}
