% VLFEATCOVDET class to wrap around the VLFeat Frame det implementation
%
%   This class wraps aronud VLFeat covariant image frames detector
%
%   The options to the constructor are the same as that for vl_hessian
%   See help vl_hessian to see those options and their default values.
%
%   See also: vl_covdet


classdef vlFeatCovdet < localFeatures.genericLocalFeatureExtractor & ...
    helpers.GenericInstaller
  properties (SetAccess=public, GetAccess=public)
    % See help vl_mser for setting parameters for vl_mser
    vl_covdet_arguments
    binPath
  end

  methods
    % The constructor is used to set the options for vl_mser call
    % See help vl_mser for possible parameters
    % The varargin is passed directly to vl_mser
    function obj = vlFeatCovdet(varargin)
      obj.detectorName = 'vlFeat Covdet';
      obj.vl_covdet_arguments = obj.configureLogger(obj.detectorName,varargin);
      obj.binPath = {which('vl_covdet') which('libvl.so')};
    end

    function [frames descriptors] = extractFeatures(obj, imagePath)
      import helpers.*;
      
      [frames descriptors] = obj.loadFeatures(imagePath,nargout > 1);
      if numel(frames) > 0; return; end;
      
      startTime = tic;
      if nargout == 1
        obj.info('Computing frames of image %s.',getFileName(imagePath));
      else
        obj.info('Computing frames and descriptors of image %s.',getFileName(imagePath));
      end
      
      img = imread(imagePath);
      if(size(img,3)>1), img = rgb2gray(img); end
      img = single(img); % If not already in uint8, then convert
      
      if nargout == 2
        [frames descriptors] = vl_covdet(img,obj.vl_covdet_arguments{:});
      elseif nargout == 1
        [frames] = vl_covdet(img,obj.vl_covdet_arguments{:});
      end
      
      timeElapsed = toc(startTime);
      obj.debug('Frames of image %s computed in %gs',...
        getFileName(imagePath),timeElapsed);
      
      obj.storeFeatures(imagePath, frames, descriptors);
    end
    
    function sign = getSignature(obj)
      sign = [helpers.fileSignature(obj.binPath{:}) ';'...
              helpers.cell2str(obj.vl_covdet_arguments)];
    end
  end
  
  methods (Static)
    function deps = getDependencies()
      deps = {helpers.VlFeatInstaller()};
    end
  end
end
