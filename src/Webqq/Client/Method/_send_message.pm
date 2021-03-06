use JSON;
use Encode;
sub Webqq::Client::_send_message{
    my($self,$msg) = @_;
    #将整个hash从UTF8还原为unicode
    $msg->{$_} = decode("utf8",$msg->{$_} ) for keys %$msg;
    my $ua = $self->{asyn_ua};
    my $send_message_callback = $msg->{cb};
    ref $cb eq 'CODE'?$send_message_callback = $cb:$send_message_callback = $self->{on_send_message};
    my $callback = sub{
        my $response = shift;   
        print $response->content() if $self->{debug};
        my $status = $self->parse_send_status_msg( $response->content() );
        if(ref $send_message_callback eq 'CODE' and defined $status){
            $send_message_callback->(
                $msg,                   #msg
                $status->{is_success},  #is_success
                $status->{status}       #status
            );
        }
    };
    my $api_url = 'http://d.web2.qq.com/channel/send_buddy_msg2';
    my @headers = (Referer=>'http://d.web2.qq.com/proxy.html?v=20110331002&callback=1&id=3');
    my $content = [$msg->{content},"",[]];
    my %s = (
        to      => $msg->{to_uin},
        face    => 570,
        content => JSON->new->utf8->encode($content),
        msg_id  =>  $msg->{msg_id},
        clientid => $self->{qq_param}{clientid},
        psessionid  => $self->{qq_param}{psessionid},
    );
    
    my $post_content = [
        r           =>  decode("utf8",JSON->new->encode(\%s)),
        clientid    =>  $self->{qq_param}{clientid},
        psessionid  =>  $self->{qq_param}{psessionid}
    ];
    if($self->{debug}){
        require URI;
        my $uri = URI->new('http:');
        $uri->query_form($post_content);    
        print $api_url,"\n";
        print $uri->query(),"\n";
    }
    $ua->post(
        $api_url,
        $post_content,
        @headers,
        $callback,
    );
}
1;
