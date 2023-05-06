/-  forums
/+  verb, dbug
/+  *sss, *etch

^-  agent:gall
%-  agent:dbug
%+  verb  &
::  listen for subscriptions on [%forums ....]
=/  sub-forums  (mk-subs forums ,[%forums %updates @ ~])

::  publish updates on [%forums %updates @ ~]
=/  pub-forums  (mk-pubs forums ,[%forums %updates @ ~])

=<
|_  =bowl:gall
+*  this  .
    da-forums  =/  da  (da forums ,[%forums %updates @ ~])
                   (da sub-forums bowl -:!>(*result:da) -:!>(*from:da) -:!>(*fail:da))
::
    du-forums  =/  du  (du forums ,[%forums %updates @ ~])
                  (du pub-forums bowl -:!>(*result:du))
::
++  on-init  `this
++  on-save  !>([sub-forums pub-forums])
++  on-load
  |=  =vase
  =/  old  !<([=_sub-forums =_pub-forums] vase)
  :-  ~
  %=  this
    sub-forums  sub-forums.old
    pub-forums  pub-forums.old
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card:agent:gall _this)
  ?+    mark  `this
  ::
      %poke-forums
    ::  Poke board host with %forums-action mark
    =+  !<(poke-forums.forums vase)
    :_  this
    :~  :*  %pass  /forums/action  
            %agent  [host.- %forums]  
            %poke  %forums-action  !>(forums-action.-)
    ==  ==
  ::
      %forums-action
    =/  act  !<(forums-action.forums vase)
    =^  cards  pub-forums  (give:du-forums [%forums %updates p.act ~] [bowl act])
    ::  Prints pub state so that we can observe change caused by poke,
    ::  Comment out line below when releasing.
    ~&  >>>  read:du-forums
    =.  cards  (weld cards ~[(~(emit-ui json bowl) act)])
    ~&  >  cards
    [cards this]
    ::
      %surf-forums
    =^  cards  sub-forums
      (surf:da-forums !<(@p (slot 2 vase)) %forums !<([%forums %updates @ ~] (slot 3 vase)))
    [cards this]
    :: 
      %sss-on-rock
    `this
    ::
      %quit-forums
    =.  sub-forums
      (quit:da-forums !<(@p (slot 2 vase)) %forums !<([%forums %updates @ ~] (slot 3 vase)))
    ~&  >  "sub-forums is: {<read:da-forums>}"
    `this
    ::
      %sss-to-pub
    ?-  msg=!<(into:du-forums (fled vase))
        [[%forums *] *]
      =^  cards  pub-forums  (apply:du-forums msg)
      [cards this]
    ==
    ::
      %sss-forums
    =/  res  !<(into:da-forums (fled vase))
    =^  cards  sub-forums  (apply:da-forums res)
    ::  Check for wave, emit wave.
    ?+    type.res  [cards this]
        %scry
      =?    cards  
          ?=(%wave what.res)
        (weld cards ~[(~(emit-ui json bowl.wave.res) forums-action.wave.res)])
      [cards this]
    ==
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card:agent:gall _this)
  ?+    -.sign  `this
      %poke-ack
    ?~  p.sign  `this
    %-  (slog u.p.sign)
    ?+    wire  `this
        [~ %sss %on-rock @ @ @ %forums %updates @ ~]
      `this
        ::
        [~ %sss %scry-request @ @ @ %forums %updates @ ~]
      =^  cards  sub-forums  (tell:da-forums |3:wire sign)
      [cards this]
    ==
  ==

::
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card:agent:gall _this)
    ?+    wire  `this
    [~ %sss %behn @ @ @ %forums %updates @ ~]  [(behn:da-forums |3:wire) this]
  ==
::
++  on-peek   _~
++  on-watch
  |=  =path
  ^-  (quip card:agent:gall _this)
  ?+    path  `this
      [%front-end %updates ~]
    :_  this
    :~  [%give %fact ~ %json !>(*^json)]
    ==
  ==
++  on-leave  _`this
++  on-fail   _`this
--
::  hc: helper core
|%
  ++  json
  =,  enjs:format
  |_  bol=bowl:gall
    ++  emit
    |=  =forums-action.forums
    ^-  card:agent:gall  
    :*  %give  
        %fact  
        ~[/front-end/updates]
        [%json !>(*^json)]
    ==
  ::
    ++  emit-ui
    ::  For board added or deleted or edited
    |=  =forums-action.forums
    ^-  card:agent:gall  
    =/  act  q.forums-action
    =/  board-name  board.p.forums-action
    ::  Sometimes the bol is from the original wave, not from this agent.
    =/  host  our.bol
    =;  jon=^json
      ~&  >  jon
      :*  %give  
          %fact  
          ~[/quorum/(scot %p host)/(scot %tas board-name)/ui]
          [%json !>(jon)]
      ==
    %-  need
    %-  de-json:html
    %-  crip
    %-  show-json
    ?+    -.act  !!
        %new-board
      !>
      :*  ^=  new-board
          :*  board=board-name
              display-name=display-name.act
              tags=tags.act
      ==  ==
      ::
        %new-thread
      =/  tags  ?>(?=([%l *] tags.act) p.tags.act)
      !>
      :*  ^=  new-thread
          :*  title=title.act
              content=content.act
              author=src.bol
              tags=tags
      ==  ==
   ::   ::
        %new-reply
      =/  parent  ?~(parent-id.act ~ (need parent-id.act))
      !>
      :*  ^=  new-reply
          :*  thread-id=thread-id.act
              parent-id=parent
              comment=comment.act
              content=content.act
      ==  ==
   ::   ::
        %delete-post
      !>
      :*  ^=  delete-post
          :*  id=id.act
      ==  ==
      ::
        %vote
      !>
      :*  ^=  vote
          :*  id=post-id.act
              dir=dir.act
      ==  ==
      ::
      ::
        %edit-content
      !>
      :*  ^=  edit-content
          :*  id=post-id.act
              content=content.act
      ==  ==
    ==
  --
--