% bp function of discriminator
% every layer's z will be activated and then input to the back layer and be
% calculated
function net = nn_bp_d(net, logits, labels)
    n = numel(net.layers);
    %% error term 
    % get the layers{n}'s error term 
    net.layers{n}.d = delta_sigmoid_cross_entropy(logits,labels);
    for l = n-1:-1:2
        back_layer = net.layers{l+1};
        % ����bp�ο���https://www.cnblogs.com/tornadomeet/p/3468450.html
        if strcmp(back_layer.type, 'conv2d')
            net.layers{l}.d = get_error_term_from_conv2d_layer(back_layer);
        % ----------------------
        elseif strcmp(back_layer.type, 'fully_connect')
            net.layers{l}.d = back_layer.d * back_layer.weights';
        % -----------------------reshape
        elseif strcmp(back_layer.type, 'reshape')
            net.layers{l}.d = reshape(back_layer.d, [size(back_layer.d,1), back_layer.input_shape(2:end)]);
        % -------------------------
        elseif strcmp(back_layer.type, 'conv2d_transpose')
            net.layers{l}.d = get_error_term_from_conv2d_transpose_layer(back_layer);
        % -------------------------
        elseif strcmp(back_layer.type, 'sub_sampling')
            net.layers{l}.d = get_error_term_from_sub_sampling_layer(back_layer);
        elseif strcmp(back_layer.type, 'atrous_conv2d')
            net.layers{l}.d = get_error_term_from_atrous_conv2d_layer(back_layer);
        % --------------------------wrong layers' type
        else
            error(['wrong net.layers.type:', back_layer.type]);
        end
        net.layers{l}.d = net.layers{l}.d .* delta_activation_function(net.layers{l});
    end
    %% get every layer's gradient
    for l = 2:n
        if strcmp(net.layers{l}.type, 'conv2d')
            [dfilter, dbiases] = calculate_gradient_for_conv2d_layer(net.layers{l-1}.a, net.layers{l});
            net.layers{l}.dfilter = dfilter;
            net.layers{l}.dbiases = dbiases;
        elseif strcmp(net.layers{l}.type, 'fully_connect')
            d = net.layers{l}.d;
            a = net.layers{l-1}.a;
            net.layers{l}.dweights = a'*d / size(d, 1);
            net.layers{l}.dbiases = mean(d, 1);
        elseif strcmp(net.layers{l}.type, 'sub_sampling')
            continue
        elseif strcmp(net.layers{l}.type, 'reshape')
            continue
        elseif strcmp(net.layers{l}.type, 'conv2d_transpose')
            [dfilter, dbiases] = calculate_gradient_for_conv2d_transpose_layer(net.layers{l-1}.a, net.layers{l});
            net.layers{l}.dfilter = dfilter;
            net.layers{l}.dbiases = dbiases;
        elseif strcmp(net.layers{l}.type, 'atrous_conv2d')
            [dfilter, dbiases] = calculate_gradient_for_atrous_conv2d_layer(net.layers{l-1}.a, net.layers{l});
            net.layers{l}.dfilter = dfilter;
            net.layers{l}.dbiases = dbiases;
        else 
            error(['error net.layers{l}.type:',net.layers{l}.type]);
        end
    end
    
end